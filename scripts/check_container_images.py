#!/usr/bin/env python3

"""Verify that every container image is declared and kept up to date.

Checks:
1. Every ``container.<name>`` referenced from ``helmfile/apps`` exists in
   ``helmfile/environments/default/container.yaml.gotmpl``.
2. Every entry in ``container.yaml.gotmpl`` (except ``default``) is targeted
   by at least one Updatecli pipeline in ``updatecli/updatecli.d``.
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONTAINER_FILE = ROOT / "helmfile" / "environments" / "default" / "container.yaml.gotmpl"
APPS_DIR = ROOT / "helmfile" / "apps"
UPDATECLI_DIR = ROOT / "updatecli" / "updatecli.d"

KEY_RE = re.compile(r"^  ([A-Za-z_]+):$", re.MULTILINE)
REFERENCE_RE = re.compile(r"container\.([A-Za-z_]+)")
TARGET_RE = re.compile(r"\$\.container\.([A-Za-z_]+)")


def container_keys():
  text = CONTAINER_FILE.read_text()
  return set(KEY_RE.findall(text))


def referenced_keys():
  references = set()
  for path in APPS_DIR.rglob("*"):
    if not path.is_file() or path.suffix not in (".yaml", ".gotmpl", ".tpl"):
      continue
    references.update(REFERENCE_RE.findall(path.read_text()))
  return references


def updatecli_targets():
  targets = set()
  for path in UPDATECLI_DIR.glob("*.yaml"):
    targets.update(TARGET_RE.findall(path.read_text()))
  return targets


def main():
  declared = container_keys()
  referenced = referenced_keys()
  targets = updatecli_targets()

  errors = []

  undeclared = sorted(referenced - declared)
  if undeclared:
    errors.append(
        "Images referenced by Helm values but missing from "
        f"{CONTAINER_FILE.relative_to(ROOT)}: {', '.join(undeclared)}"
    )

  unmanaged = sorted(declared - {"default"} - targets)
  if unmanaged:
    errors.append(
        "Images without an Updatecli target in "
        f"{UPDATECLI_DIR.relative_to(ROOT)}: {', '.join(unmanaged)}"
    )

  stale = sorted(targets - declared)
  if stale:
    errors.append(
        "Updatecli pipelines target unknown container images: " + ", ".join(stale)
    )

  if errors:
    for error in errors:
      print(f"ERROR: {error}", file=sys.stderr)
    return 1

  print(f"OK: {len(declared)} container images declared and updated.")
  return 0


if __name__ == "__main__":
  sys.exit(main())
