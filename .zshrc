############### start variables ###############
# use gcr-ssh-agent for ssh keyring management
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# set bat theme
export BAT_THEME=base16-256

# set editor
export EDITOR=nvim

# path
export PATH=$PATH:~/bin:~/.local/bin:~/go/bin:~/.asdf/shims:/opt/homebrew/bin:/opt/homebrew/sbin:/Applications/Postgres.app/Contents/Versions/16/bin
############### end variables ###############

############### start history ###############
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
############## end history ###############

############### start zinit ###############
# Set the directory to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if needed
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source zinit
source "${ZINIT_HOME}/zinit.zsh"
############### end zinit ###############

############### start plugins ###############
# syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# auto-completions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
autoload -U compinit && compinit
zinit cdreplay -q
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# auto-suggestions
zinit light zsh-users/zsh-autosuggestions
############### end plugins ###############

############### start shell integrations ###############
eval "$(direnv hook zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(thefuck --alias fk)"

# load apps installed via homebrew (macOS only)
if [ -d "/opt/homebrew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  source $(brew --prefix nvm)/nvm.sh
  
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  export GPG_TTY=$(tty)
  gpgconf --launch gpg-agent
# load apps installed via yay (linux only)
else
  if [ -d "/usr/share/nvm" ]; then
    source /usr/share/nvm/init-nvm.sh
    nvm use default --silent
  fi
fi

# load oh-my-posh if not using default Mac terminal
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/base.yaml)"
fi

# fzf
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# worktrunk
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

############### end shell integrations ###############

############### start keybindings ###############
# set emacs keybindings
bindkey -e

# browse through historical commands
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
############### end keybindings ###############

############### start aliases ###############
# add snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# clear
alias c="clear"

# eza
alias ls="eza --color=always --icons=always --long --git"
alias tree="ls --tree"

# bat
alias cat="bat"

# neovim
alias vim="nvim"
alias neovim="nvim"

# ansible
alias setup-servers="ansible-playbook /run/media/ted/Storage/Seafile/Linux\ Scripts/ansible/playbooks/setup.yaml -i /run/media/ted/Storage/Seafile/Linux\ Scripts/ansible/hosts --ask-become-pass"
alias update-servers="ansible-playbook /run/media/ted/Storage/Seafile/Linux\ Scripts/ansible/playbooks/update.yaml -i /run/media/ted/Storage/Seafile/Linux\ Scripts/ansible/hosts --ask-become-pass --ask-vault-pass"

# yay
alias remove-orphaned="yay -Qtdq | yay -Rns -"

# tmuxinator
alias mux="tmuxinator"

# tmux project layout (nvim | opencode | lazygit) in current directory
tt() {
  if [[ -z "$TMUX" ]]; then
    echo "tt: must be run inside tmux" >&2
    return 1
  fi

  local wt_path="$PWD"

  # rename window to current directory name
  tmux rename-window "${wt_path:t}"

  # split into 3 vertical panes (39% / 34% / 27%)
  local wid
  wid=$(tmux display-message -p '#{window_id}')
  tmux split-window -h -t "$wid" -c "$wt_path" -p 61
  tmux split-window -h -t "$wid" -c "$wt_path" -p 44

  # launch programs: pane 1 = nvim, pane 2 = opencode, pane 3 = lazygit
  tmux send-keys -t "$wid.1" "nvim" Enter
  tmux send-keys -t "$wid.2" "opencode" Enter
  tmux send-keys -t "$wid.3" "lazygit" Enter

  # focus pane 2 (opencode)
  tmux select-pane -t "$wid.2"
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

# aws
alias aws-login='aws sso login --sso-session regular-cloud && eval $(aws configure export-credentials --profile regular --format env)'
alias aws-login-gov='aws sso login --sso-session gov-cloud && eval $(aws configure export-credentials --profile gov --format env)'
############### end aliases ###############
