# herdr equivalents of the tmux helpers in tmux-functions.zsh.
# Both files can be sourced at once; the tmux versions are untouched.
#
# Depends on _resolve_directory() from tmux-functions.zsh (zoxide lookup).
if ! typeset -f _resolve_directory >/dev/null; then
  source ~/.config/zsh/tmux-functions.zsh
fi

# Start the herdr server if it isn't already running.
# The tmux CLI starts a server implicitly; the herdr CLI does not -- it fails
# with `server_not_running` -- so the server has to exist before we build a
# workspace with it.
_herdr_ensure_server() {
  herdr status server 2>/dev/null | grep -q '^status: running' && return 0

  herdr server >/dev/null 2>&1 &
  disown 2>/dev/null

  local i
  for i in {1..50}; do
    sleep 0.1
    herdr status server 2>/dev/null | grep -q '^status: running' && return 0
  done

  echo "h: timed out waiting for the herdr server to start" >&2
  return 1
}

# herdr project workspace (nvim | opencode) -- the herdr twin of `tp`.
#
#   h            pick a directory interactively via zoxide
#   h nova       jump straight there via zoxide frecency
#
# Layout, matching `tp`:
#   tab 1 "code":  nvim | opencode   (50/50 vertical split, focus on nvim)
#   tab 2 "shell": plain shell
h() {
  local project_dir
  project_dir=$(_resolve_directory h "$@") || return $?

  local workspace_name="${project_dir:t}"

  _herdr_ensure_server || return $?

  # if the workspace already exists, just focus it (tmux: has-session)
  local existing
  existing=$(herdr workspace list 2>/dev/null |
    jq -r --arg name "$workspace_name" \
      '.result.workspaces[]? | select(.label == $name) | .workspace_id' |
    head -1)

  if [[ -n "$existing" ]]; then
    # visible feedback: without this, focusing the workspace you are already
    # on is indistinguishable from the function doing nothing
    echo "h: focusing existing workspace '${workspace_name}' (${project_dir})"
    herdr workspace focus "$existing" >/dev/null || return $?
  else
    echo "h: creating workspace '${workspace_name}' (${project_dir})"

    # tab 1: nvim | opencode
    local created
    created=$(herdr workspace create --cwd "$project_dir" --label "$workspace_name" --focus) || return $?

    local ws tab1 p1
    ws=$(jq -r '.result.workspace.workspace_id // empty' <<<"$created")
    tab1=$(jq -r '.result.tab.tab_id // empty' <<<"$created")
    p1=$(jq -r '.result.root_pane.pane_id // empty' <<<"$created")

    if [[ -z "$ws" || -z "$tab1" || -z "$p1" ]]; then
      echo "h: failed to create workspace: $created" >&2
      return 1
    fi

    # --no-focus keeps the focus on the nvim pane (tmux: select-pane -t .1)
    local p2
    p2=$(herdr pane split --pane "$p1" --direction right --ratio 0.5 \
      --cwd "$project_dir" --no-focus | jq -r '.result.pane.pane_id // empty') || return $?

    if [[ -z "$p2" ]]; then
      echo "h: failed to split pane" >&2
      return 1
    fi

    herdr tab rename "$tab1" code >/dev/null

    # pane run sends the command and Enter atomically -- no send-keys race
    herdr pane run "$p1" nvim >/dev/null
    herdr pane run "$p2" opencode >/dev/null

    # tab 2: shell
    herdr tab create --workspace "$ws" --cwd "$project_dir" --label shell --no-focus >/dev/null

    # land on the code tab (tmux: select-window -t $wid1)
    herdr tab focus "$tab1" >/dev/null
  fi

  # Focusing only changes server-side state. If we are not already inside a
  # herdr pane there is no client rendering it, so attach one.
  # tmux: switch-client when inside $TMUX, attach-session when outside.
  # The guard is required, not cosmetic: experimental.allow_nested = false
  # makes herdr refuse to launch from inside a pane.
  if [[ -z "$HERDR_ENV" ]]; then
    herdr
  fi
}
