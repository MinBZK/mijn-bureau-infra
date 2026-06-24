"""
Gitlint extra rule to validate that the message title is of the form
"<gitmoji>(<scope>) <subject>"
"""
from __future__ import unicode_literals

import os
import re
from typing import Any

import requests
from gitlint.rules import CommitMessageTitle, LineRule, RuleViolation, CommitRule


class GitmojiTitle(LineRule):
    """
    This rule will enforce that each commit title is of the form "<gitmoji>(<scope>) <subject>"
    where gitmoji is an emoji from the list defined in https://gitmoji.carloscuesta.me and
    subject should be all lowercase
    """

    id = "UC1"
    name = "title-should-have-gitmoji-and-scope"
    target = CommitMessageTitle

    def validate(self, title: str, _commit: Any):
        """
        Download the list possible gitmojis from the project's github repository and check that
        title contains one of them.
        """
        gitmojis = requests.get(
            "https://raw.githubusercontent.com/carloscuesta/gitmoji/master/packages/gitmojis/src/gitmojis.json"
        ).json()["gitmojis"]
        emojis = [item["emoji"] for item in gitmojis]

        pattern = r"^({:s})\s?\(.*\)\s[a-zA-Z].*$".format("|".join(emojis))
        if not re.search(pattern, title):
            violation_msg = 'Title does not match regex "<gitmoji> [(<scope>)] <subject>"'

            # Special case for deps, updatecli forces a : after deps
            depspattern = r"^({:s})\(deps\):\s[a-zA-Z].*$".format("|".join(emojis))
            if not re.search(depspattern, title):
              return [RuleViolation(self.id, violation_msg, title)]

        # Dynamically generate scopes from folder names in helmfile/apps
        # Use the repository base directory from the GITLINT_GIT_CONTEXT environment variable if available
        base_dir = os.environ.get("GITLINT_GIT_CONTEXT", os.getcwd())
        apps_dir = os.path.join(base_dir, "helmfile", "apps")
        scopes = [name for name in os.listdir(apps_dir) if os.path.isdir(os.path.join(apps_dir, name))]
        scopes.append("settings")
        scopes.append("deps")
        scopes.append("docs")
        scopes.append("tests")
        scopes.append("policies")
        scopes.append("ci")
        scopes.append("other")
        pattern = r"^({:s})\s?\({:s}\)\s[a-zA-Z].*$".format("|".join(emojis), "|".join(scopes))
        if not re.search(pattern, title):
            violation_msg = 'The scope should be one of: {:s}'.format(", ".join(scopes))
            return [RuleViolation(self.id, violation_msg, title)]


# also add a sign-off check to the gitlint config file, to ensure that all commits are signed off
class SignOff(CommitRule):
    """
    This rule will enforce that each commit message contains a sign-off line.
    """

    id = "UC2"
    name = "commit-should-have-sign-off"

    def _message_to_text(self, message: Any) -> str:
        """Convert a gitlint commit message object to plain text."""
        if isinstance(message, str):
            return message

        full = getattr(message, "full", None)
        if isinstance(full, str):
            return full

        title = getattr(message, "title", "")
        body = getattr(message, "body", "")
        title_text = title if isinstance(title, str) else str(title)
        body_text = body if isinstance(body, str) else str(body)

        combined = "\n\n".join(part for part in [title_text, body_text] if part)
        return combined if combined else str(message)

    def validate(self, commit: Any):
        """
        Check if the commit message contains a sign-off line.
        """
        sign_off_pattern = r"^Signed-off-by: (.+) <(.+)>$"
        message_text = self._message_to_text(commit.message)
        if not re.search(sign_off_pattern, message_text, re.MULTILINE):
            violation_msg = "Commit message does not contain a sign-off line."
            return [RuleViolation(self.id, violation_msg, message_text)]
