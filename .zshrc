# Awesome prompt (starship)
type starship > /dev/null
if [ ! $? -eq 0 ]; then
	echo "Install Starship"
	curl -fsSL https://starship.rs/install.sh | bash
fi
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

PATH=/opt/asdf-vm/bin:$HOME/.asdf/shims:$HOME/.krew/bin:$PATH

. $HOME/.config/zsh/primer.zsh
. $HOME/.config/zsh/functions.zsh

type zinit > /dev/null
if [ ! $? -eq 0]; then
	mkdir ~/.zinit
	git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

zplugin pack for zsh
zinit pack for any-node
zinit pack for any-gem
zplugin pack"default+keys" for fzf

zinit lucid for OMZP::tmux

# Autosuggestions & fast-syntax-highlighting
zinit for \
	zdharma/history-search-multi-word \
	light-mode agkozak/zsh-z \
	light-mode marzocchi/zsh-notify \
	light-mode OMZL::history.zsh \

zinit wait'!' lucid for \
	light-mode PZT::modules/utility/init.zsh \

zinit wait'!' lucid for \
	light-mode OMZP::colorize \
	light-mode OMZP::command-not-found \
	light-mode OMZP::colored-man-pages \
	light-mode OMZP::mvn \

zinit wait'!' lucid atload"zicompinit; zicdreplay" for \
	light-mode OMZL::completion.zsh \

zinit lucid for \
	light-mode OMZL::key-bindings.zsh 

# GIT
zinit wait lucid for \
	light-mode davidde/git

zinit wait lucid light-mode for \
	as"completion" \
		OMZ::plugins/docker/_docker \
		OMZ::plugins/composer/composer.plugin.zsh \
      	OMZ::plugins/thefuck/thefuck.plugin.zsh \
	  	zsh-users/zsh-completions \
	  	OMZP::asdf \
		OMZP::helm \
		OMZP::doctl
#		OMZP::kubectl \

zinit snippet OMZL::git.zsh
zinit snippet OMZP::git

zinit snippet OMZP::command-not-found

#################################################################
# FUZZY SEARCH AND MOVEMENT
#
# Install a fuzzy finder (fzf/fzy) and necessary completions
# and key bindings.
#

# Install `fzf` bynary and tmux helper script
zcommand from"gh-r";         zload junegunn/fzf-bin
zcommand pick"bin/fzf-tmux"; zload junegunn/fzf
# Create and bind multiple widgets using fzf
turbo0 multisrc"shell/{completion,key-bindings}.zsh" \
        id-as"junegunn/fzf_completions" pick"/dev/null"
    zload junegunn/fzf

# Fuzzy movement and directory choosing
turbo1; zload rupa/z               # autojump command
turbo0; zload andrewferrier/fzf-z  # Pick from most frecent folders with `Ctrl+g`
turbo0; zload changyuheng/fz       # lets z+[Tab] and zz+[Tab]

# Like `z` command, but opens a file in vim based on frecency
zcommand pick"v"; zload rupa/v

# Install `fzy` fuzzy finder, if not yet present in the system
# Also install helper scripts for tmux and dwtm
turbo0 as"command" if'[[ -z "$commands[fzy]" ]]' \
       make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
    zload jhawthorn/fzy
# Install fzy-using widgets
turbo0 silent; zload aperezdc/zsh-fzy
bindkey '\ec' fzy-cd-widget
bindkey '^T'  fzy-file-widget

# Fuzzy search by `Ctrl+P` a file and open in `$EDITOR`
# Implements it's own fuzzy search
turbo0; zload mafredri/zsh-async
turbo0; zload seletskiy/zsh-fuzzy-search-and-edit
bindkey '^P' fuzzy-search-and-edit
export EDITOR=${EDITOR:-vim}

#################################################################
# INSTALL `k` COMMAND AND GENERATE COMPLITIONS
#
turbo0; zload RobSis/zsh-completion-generator
turbo1 atclone"gencomp k; ZINIT[COMPINIT_OPTS]='-i' zpcompinit" atpull'%atclone'
    zload supercrabtree/k

# Add `git dsf` command to git
zcommand pick"bin/git-dsf"; zload zdharma/zsh-diff-so-fancy

# Install gitcd function to clone git repository and cd into it
turbo1; zload lainiwa/gitcd
export GITCD_TRIM=1
export GITCD_HOME=${HOME}/tmp

zload zsh-users/zsh-completions

# Syntax highlighting
# (compinit without `-i` spawns warning on `sudo -s`)
turbo0 atinit"ZINIT[COMPINIT_OPTS]='-i' zpcompinit; zpcdreplay"
    zload zdharma/fast-syntax-highlighting

# Autosuggestions
# Note: should go _after_ syntax highlighting plugin
turbo0 atload"_zsh_autosuggest_start"; zload zsh-users/zsh-autosuggestions
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Zstyle.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' list-colors $LS_COLORS
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' rehash true

# sharkdp/fd
#zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
#zinit light sharkdp/fd

# sharkdp/bat
#zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
#zinit light sharkdp/bat

# ogham/exa, replacement for ls
#zinit ice wait"2" lucid from"gh-r" as"program" mv"exa* -> exa"
#zinit light ogham/exa

#zinit ice as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
#    atpull'%atclone' src"zhook.zsh"
#zinit light direnv/direnv

#zinit ice from"gh-r" as"program" mv"gotcha_* -> gotcha"
#zinit light b4b4r07/gotcha

#zinit ice as"program" pick"yank" make
#zinit light mptre/yank

#zinit ice as"program" cp"wd.sh -> wd" mv"_wd.sh -> _wd" \
#    atpull'!git reset --hard' pick"wd"
#zinit light mfaerevaag/wd

zinit snippet OMZP::archlinux

# Load base zsh configuration
. $HOME/.config/zsh/zsh_configuration
. $HOME/.config/zsh/aliases.zsh

autoload -Uz compinit
compinit

zpcompinit

source <(kubectl completion zsh)
source <(helm completion zsh)

#################################################################
# REMOVE TEMPORARY FUNCTIONS
#
unset -f turbo0
unset -f turbo1
unset -f turbo2
unset -f zload
unset -f zsnippet