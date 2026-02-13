## -- Profiling hook for debugging
## zmodload zsh/zprof

## --- COMPLETIONS (The "Better than Bash" part) ---
autoload -Uz compinit
if [[ -n ${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump(#qN.mh+24) ]]; then
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
else
  compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
fi

# Enable visual menu for Tab completion
zstyle ':completion:*' menu select true
# Use colors in the completion menu (matches your 'ls' colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Make the menu look organized
zstyle ':completion:*:descriptions' format '➤ %B%d%b'

## --- OPTIONS ---
setopt autocd              # Type a folder name to 'cd' into it
setopt autopushd           # Keeps a history of directories you've visited
setopt interactivecomments # Allow comments in the terminal (e.g., # like this)
setopt correct             # Spellcheck for commands
setopt noclobber           # Prevent > from overwriting files (use >| to force)
setopt histverify          # Expand history (!! !$) inline before executing
setopt extendedglob        # Enable advanced globbing (e.g., **/*.py, negation)

## --- CORRECTION PROMPT ---
SPROMPT='Correct %B%F{red}%U%R%b%f%u to %F{green}%r%f? [%By%bes|%BN%bo|%Be%bdit|%Ba%bbort] '

## --- COLORS ---
eval "$(dircolors -b)"

## --- ALIASES ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

## --- KEYBINDINGS (Fixes Delete/Home/End in WezTerm)
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# --- Go & Neovim ---
export PATH=/usr/local/go/bin:$PATH
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# --- Python (uv) ---
export PATH="$HOME/.local/bin:$PATH"

# --- AI & GPU Tools ---
# CUDA toolkit
export PATH="/usr/local/cuda/bin:$PATH"
# llama.cpp shared libraries
export LD_LIBRARY_PATH="$HOME/tools/llama.cpp/build/bin:$LD_LIBRARY_PATH"

# --- WSL Specific Aliases ---
alias open='explorer.exe'
alias clip='clip.exe'

## --- THE PROMPT (Starship) ---
eval "$(starship init zsh)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

## -- Syntax Highlighting MUST be very last line
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## -- Profiling hook for debugging
## zprof
