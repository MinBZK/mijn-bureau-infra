"""Local-only RAG backend for Conversations.

Stores parsed document text in the shared Django cache (Valkey) and performs a
simple keyword search over cached chunks. This avoids the external Albert API
for document indexing and retrieval; it is intended for deployments without an
Albert API key. Parsing itself is delegated to RAG_DOCUMENT_PARSER (with OCR,
when configured).

Trade-offs versus a vector store: no semantic ranking (keyword overlap only),
and documents expire from the cache after the configured timeout.

Note: the MijnBureau build of conversations uses stdlib logging; structlog is
not installed in the image.
"""

import logging
import re
import uuid
from typing import Optional

from django.conf import settings
from django.core.cache import cache
from django.utils.module_loading import import_string

from chat.agent_rag.constants import RAGWebResult, RAGWebResults, RAGWebUsage
from chat.agent_rag.document_rag_backends.base_rag_backend import BaseRagBackend

logger = logging.getLogger(__name__)

_CACHE_KEY = "local_rag:{}"
_CHUNK_SIZE = 1500  # characters per searchable/returned chunk
_WORD_RE = re.compile(r"\w+")


class LocalRagBackend(BaseRagBackend):
    """Store parsed documents in the Django cache and search them by keyword."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Same parser selection as the upstream backends.
        parser_class = import_string(settings.RAG_DOCUMENT_PARSER)
        self.parser = parser_class()

    @staticmethod
    def _timeout():
        return getattr(settings, "LOCAL_RAG_CACHE_TIMEOUT", 7 * 24 * 3600)

    def _load(self, collection_id):
        result = cache.get(_CACHE_KEY.format(collection_id))
        if result is None:
            logger.warning("local_rag: collection %s not in cache", collection_id)
            return {"name": "", "documents": {}}
        return result

    def create_collection(self, name: str, description: Optional[str] = None) -> str:
        """Create an empty collection and return its id.

        Callers differ: the conversation flow uses the return value, while
        `_ensure_project_collection` reads `self.collection_id` back from the
        instance afterwards (like the Albert backend), so both must be set.
        """
        collection_id = str(uuid.uuid4())
        cache.set(
            _CACHE_KEY.format(collection_id),
            {"name": name, "description": description or "", "documents": {}},
            timeout=self._timeout(),
        )
        self.collection_id = collection_id
        return collection_id

    def store_document(self, name: str, content: str, **kwargs) -> Optional[str]:
        """Store the parsed markdown under the current collection; return its id."""
        if not self.collection_id:
            raise RuntimeError("The RAG backend requires collection_id")
        document_id = str(uuid.uuid4())
        collection = self._load(self.collection_id)
        collection["documents"][document_id] = {"name": name, "content": content}
        cache.set(
            _CACHE_KEY.format(self.collection_id), collection, timeout=self._timeout()
        )
        logger.info(
            "local_rag: stored %s (%d chars) as %s in %s",
            name,
            len(content),
            document_id,
            self.collection_id,
        )
        return document_id

    def delete_collection(self, **kwargs) -> None:
        """Drop the whole collection from the cache."""
        if self.collection_id:
            cache.delete(_CACHE_KEY.format(self.collection_id))

    def delete_document(self, document_id: str, **kwargs) -> None:
        """Remove one document from the current collection."""
        if not self.collection_id:
            return
        collection = self._load(self.collection_id)
        if collection["documents"].pop(document_id, None) is not None:
            cache.set(
                _CACHE_KEY.format(self.collection_id), collection, timeout=self._timeout()
            )

    def search(
        self,
        query: str,
        results_count: int = 4,
        document_name: Optional[str] = None,
        document_id: Optional[str] = None,
        **kwargs,
    ) -> RAGWebResults:
        """Keyword-overlap search over cached chunks of all accessible collections."""
        terms = [t for t in _WORD_RE.findall(query.lower()) if len(t) > 2]
        scored = []
        for collection_id in self.get_all_collection_ids():
            collection = self._load(collection_id)
            for doc_id, doc in collection["documents"].items():
                if document_id and doc_id != document_id:
                    continue
                if document_name and doc["name"] != document_name:
                    continue
                content = doc["content"]
                for start in range(0, len(content), _CHUNK_SIZE):
                    chunk = content[start : start + _CHUNK_SIZE]
                    lowered = chunk.lower()
                    hits = sum(lowered.count(term) for term in terms)
                    # A query without usable terms (very short input) returns
                    # the first chunk of each document, so the model still
                    # sees the beginning of every attached document.
                    if not terms and start > 0:
                        continue
                    scored.append((hits, doc["name"], chunk))

        scored.sort(key=lambda item: item[0], reverse=True)
        results = [
            RAGWebResult(url=name, content=chunk, score=min(1.0, hits / max(len(terms), 1)))
            for hits, name, chunk in scored[:results_count]
            if hits or not terms
        ]
        return RAGWebResults(data=results, usage=RAGWebUsage())
