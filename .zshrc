############### start variables ###############
# use gcr-ssh-agent for ssh keyring management
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# set bat theme
export BAT_THEME=base16-256

# path
export PATH=$PATH:~/bin:~/.local/bin:~/go/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Applications/Postgres.app/Contents/Versions/16/bin
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

# asdf
if [ -d "$HOME/.asdf" ]; then
  . "$HOME/.asdf/asdf.sh"
fi
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
############### end aliases ###############
