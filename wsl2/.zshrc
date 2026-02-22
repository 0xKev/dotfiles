## -- Profiling hook for debugging
## zmodload zsh/zprof

# --- COMPLETIONS ---
autoload -Uz compinit
if [[ -n ${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump(#qN.mh+24) ]]; then
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
else
  compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
fi

zstyle ':completion:*' menu select true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '➤ %B%d%b'
# Case-insensitive completion (you'll thank yourself later)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- HISTORY ---
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Share history across all sessions
setopt HIST_IGNORE_DUPS       # Don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate when new one is added
setopt HIST_IGNORE_SPACE      # Prefix with space to keep a command out of history
setopt HIST_REDUCE_BLANKS     # Trim superfluous whitespace from history
setopt INC_APPEND_HISTORY     # Write immediately, not on shell exit

# --- OPTIONS ---
setopt autocd
setopt autopushd
setopt pushdignoredups         # Don't push duplicate dirs onto the stack
setopt interactivecomments
setopt correct
setopt noclobber
setopt histverify
setopt extendedglob

# --- CORRECTION PROMPT ---
SPROMPT='Correct %B%F{red}%U%R%b%f%u to %F{green}%r%f? [%By%bes|%BN%bo|%Be%bdit|%Ba%bbort] '

# --- COLORS ---
eval "$(dircolors -b)"

# --- ALIASES ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# --- WSL-SPECIFIC ---
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  alias open='explorer.exe'
  alias clip='clip.exe'
fi

# --- KEYBINDINGS ---
bindkey "^[[3~" delete-char
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line

# --- PATH (guarded) ---
_prepend_path() { [[ -d "$1" ]] && path=("$1" $path) }

_prepend_path "/usr/local/go/bin"
_prepend_path "$HOME/go/bin"
_prepend_path "/opt/nvim-linux-x86_64/bin"
_prepend_path "$HOME/.local/bin"
_prepend_path "/usr/local/cuda/bin"

unfunction _prepend_path

# --- LD_LIBRARY_PATH (guarded) ---
if [[ -d "$HOME/tools/llama.cpp/build/bin" ]]; then
  export LD_LIBRARY_PATH="$HOME/tools/llama.cpp/build/bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# --- NVM (lazy-loaded to save ~300ms on every shell launch) ---
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # Placeholder functions that load nvm on first use
  _lazy_nvm() {
    unfunction nvm node npm npx 2>/dev/null
    \. "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  }
  nvm()  { _lazy_nvm; nvm  "$@" }
  node() { _lazy_nvm; node "$@" }
  npm()  { _lazy_nvm; npm  "$@" }
  npx()  { _lazy_nvm; npx  "$@" }
fi

# --- PROMPT (Starship) ---
eval "$(starship init zsh)"

# --- PLUGINS (guarded) ---
if [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  print -P "%F{yellow}warn:%f zsh-autosuggestions not found at ~/.zsh/zsh-autosuggestions/"
fi

# Syntax highlighting MUST be last
if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
  print -P "%F{yellow}warn:%f zsh-syntax-highlighting not found at ~/.zsh/zsh-syntax-highlighting/"
fi

## -- Profiling hook for debugging
## zprof
