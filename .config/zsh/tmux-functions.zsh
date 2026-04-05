# resolve a directory from an argument using zoxide, or prompt interactively
_resolve_directory() {
  local func_name="$1"
  shift

  if [[ -n "$1" ]]; then
    if [[ -d "$1" ]]; then
      echo "${1:A}"
    else
      zoxide query -- "$@" 2>/dev/null || {
        echo "${func_name}: no directory found for '$*'" >&2
        return 1
      }
    fi
  else
    zoxide query --interactive 2>/dev/null || return 1
  fi
}

# ensure a default tmux session exists at $HOME so new terminals don't land in a project directory
_ensure_default_session() {
  if ! tmux has-session -t "=default" 2>/dev/null; then
    tmux new-session -d -s default -c "$HOME"
  fi
}

# tmux project layout (nvim | opencode | lazygit) in current window
tt() {
  local wt_path
  wt_path=$(_resolve_directory tt "$@") || return $?

  local session_name="${wt_path:t}"

  if [[ -n "$TMUX" ]]; then
    # inside tmux: set up panes in the current window
    tmux rename-window "$session_name"

    local wid
    wid=$(tmux display-message -p '#{window_id}')

    # change current pane to the target directory
    cd "$wt_path"
    tmux split-window -h -t "$wid" -c "$wt_path" -p 61
    tmux split-window -h -t "$wid" -c "$wt_path" -p 44

    # launch programs: pane 1 = nvim, pane 2 = opencode, pane 3 = lazygit
    tmux send-keys -t "$wid.1" "nvim" Enter
    tmux send-keys -t "$wid.2" "opencode" Enter
    tmux send-keys -t "$wid.3" "lazygit" Enter

    # focus pane 2 (opencode)
    tmux select-pane -t "$wid.2"
  else
    # outside tmux: ensure a default session exists, then create project session
    _ensure_default_session
    tmux new-session -d -s "$session_name" -c "$wt_path"
    local wid
    wid=$(tmux list-windows -t "=$session_name" -F '#{window_id}' | head -1)
    tmux split-window -h -t "$wid" -c "$wt_path" -p 61
    tmux split-window -h -t "$wid" -c "$wt_path" -p 44

    tmux send-keys -t "$wid.1" "nvim" Enter
    tmux send-keys -t "$wid.2" "opencode" Enter
    tmux send-keys -t "$wid.3" "lazygit" Enter

    tmux select-pane -t "$wid.2"
    tmux attach-session -t "=$session_name"
  fi
}

# tmux project session (nvim+lazygit | opencode | shell)
tp() {
  local project_dir
  project_dir=$(_resolve_directory tp "$@") || return $?

  local session_name="${project_dir:t}"

  # if session already exists, attach to it
  if tmux has-session -t "=$session_name" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "=$session_name"
    else
      tmux attach-session -t "=$session_name"
    fi
    return 0
  fi

  # window 1: nvim | lazygit (50/50 vertical split)
  if [[ -z "$TMUX" ]]; then
    _ensure_default_session
  fi
  tmux new-session -d -s "$session_name" -c "$project_dir"
  local wid1
  wid1=$(tmux list-windows -t "=$session_name" -F '#{window_id}' | head -1)
  tmux split-window -h -t "$wid1" -c "$project_dir" -p 50
  tmux send-keys -t "$wid1.1" "nvim" Enter
  tmux send-keys -t "$wid1.2" "lazygit" Enter
  tmux select-pane -t "$wid1.1"

  # window 2: opencode
  local wid2
  wid2=$(tmux new-window -t "=$session_name" -c "$project_dir" -P -F '#{window_id}')
  tmux send-keys -t "$wid2" "opencode" Enter

  # window 3: shell
  tmux new-window -t "=$session_name" -c "$project_dir"

  # select window 1 (code)
  tmux select-window -t "$wid1"

  # attach to session
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "=$session_name"
  else
    tmux attach-session -t "=$session_name"
  fi
}

# worktree + tmux project layout
wtt() {
  if [[ -z "$TMUX" ]]; then
    echo "wtt: must be run inside tmux" >&2
    return 1
  fi

  # try wt switch; if branch doesn't exist, retry with --create
  if ! wt switch "$@" 2>/dev/null; then
    wt switch --create "$@" || return $?
  fi

  # set up panes via tt
  tt

  # override window name with repo/branch
  local repo_root repo_name branch sanitized_branch
  repo_root=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  repo_root="${repo_root%/.git}"
  repo_name="${repo_root:t}"
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  sanitized_branch="${branch//\//-}"
  sanitized_branch="${sanitized_branch//\\/-}"
  tmux rename-window "${repo_name}/${sanitized_branch}"
}
