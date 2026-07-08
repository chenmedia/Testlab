#!/bin/bash
# SessionStart hook: ensure gstack is installed for this session.
# gstack lives in the user skills dir (~/.claude/skills), which is not
# persisted across fresh remote containers, so reinstall it if missing.
set -uo pipefail

# Only run in Claude Code on the web / remote environments.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

GSTACK_DIR="$HOME/.claude/skills/gstack"

# Idempotent: skip the install when gstack is already present.
if [ ! -d "$GSTACK_DIR/bin" ]; then
  echo "Installing gstack into $GSTACK_DIR ..." >&2
  if git clone --single-branch --depth 1 \
       https://github.com/garrytan/gstack.git "$GSTACK_DIR" >&2; then
    # ./setup exits non-zero when the sandboxed browser download is blocked
    # by network egress policy; the skills + browse binary still build, so a
    # setup failure must not block session startup.
    ( cd "$GSTACK_DIR" && ./setup ) >&2 \
      || echo "gstack setup finished with warnings (browser download may be blocked)." >&2
  else
    echo "gstack clone failed; skipping (session will start without gstack)." >&2
  fi
fi

exit 0
