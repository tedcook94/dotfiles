#!/usr/bin/env bash
# Mirror each tab's position in the tab bar into its label as "[N] name",
# so the digit shown is the digit prefix+N responds to.
#
# Invoked by herdr on tab.created / tab.closed / tab.moved / tab.renamed, and
# manually via `herdr plugin action invoke local.tab-numbers.renumber`.
#
# Two properties matter here:
#
#   Idempotent -- a tab is renamed only when the computed label differs from
#   the current one. A second run issues zero renames. This is what stops the
#   tab.renamed hook from recursing: our own rename settles on the next pass.
#
#   Stateless -- the number is re-read from the API every run and the event
#   payload is ignored entirely. So this does not depend on the (undocumented)
#   shape of HERDR_PLUGIN_EVENT_JSON, and it self-heals from any race with a
#   concurrent layout script.

set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

if ! command -v jq >/dev/null 2>&1; then
  echo "tab-numbers: jq is required but was not found on PATH" >&2
  exit 1
fi

# Serialise concurrent hook invocations: four event types can fire in quick
# succession (h() creates a tab, renames another, then focuses), and two
# overlapping runs could otherwise both decide to rename the same tab.
lock_dir="${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}"
if command -v flock >/dev/null 2>&1; then
  mkdir -p "$lock_dir" 2>/dev/null
  exec 9>"$lock_dir/renumber.lock" || exec 9>/dev/null
  flock -w 5 9 || exit 0
fi

renamed=0
inspected=0

workspaces=$("$herdr" workspace list 2>/dev/null | jq -r '.result.workspaces[]?.workspace_id')
if [[ -z "$workspaces" ]]; then
  echo "tab-numbers: no workspaces (server not running?)" >&2
  exit 0
fi

while IFS= read -r ws; do
  [[ -n "$ws" ]] || continue

  # Number by LIST POSITION, not by the API's `.number` field.
  #
  # `.number` looks like the obvious choice but is wrong: it is a stable
  # per-workspace handle that is allocated monotonically, never recycled, and
  # never reordered. Closing a tab leaves a gap; dragging a tab does not change
  # it. Verified empirically that prefix+N follows the tab's POSITION in the
  # bar, and that `tab list` returns tabs in that same visual order.
  tabs=$("$herdr" tab list --workspace "$ws" 2>/dev/null \
    | jq -r '.result.tabs | to_entries[]
             | [.value.tab_id, (.key + 1 | tostring), .value.label] | @tsv')

  while IFS=$'\t' read -r tab_id number label; do
    [[ -n "$tab_id" && -n "$number" ]] || continue
    inspected=$((inspected + 1))

    # Strip an existing "[N] " prefix so renumbering is repeatable and a tab
    # never accumulates "[2] [1] name".
    clean="$label"
    if [[ "$label" =~ ^\[[0-9]+\]\ ?(.*)$ ]]; then
      clean="${BASH_REMATCH[1]}"
    fi

    if [[ -n "$clean" && ! "$clean" =~ ^[0-9]+$ ]]; then
      desired="[$number] $clean"
    else
      # Herdr's default tab names are bare numbers, so a plain "[1] 1" would
      # just say the same thing twice. Collapse those to "[1]".
      desired="[$number]"
    fi

    # The idempotence guard. Everything above is pure computation; this is the
    # only place a mutation happens, and only on a genuine difference.
    if [[ "$desired" != "$label" ]]; then
      if "$herdr" tab rename "$tab_id" "$desired" >/dev/null 2>&1; then
        renamed=$((renamed + 1))
        echo "tab-numbers: $tab_id '$label' -> '$desired'"
      else
        echo "tab-numbers: failed to rename $tab_id" >&2
      fi
    fi
  done <<<"$tabs"
done <<<"$workspaces"

echo "tab-numbers: event=${HERDR_PLUGIN_EVENT:-manual} inspected=$inspected renamed=$renamed"
exit 0
