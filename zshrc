fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

# Show contents of directory after cd-ing into it
# chpwd() {
#   ls -lrthG
# }

cdl()
{
  if [ "$#" = 0 ]; then
    cd ~ && ls -lrthG
  elif [ -d "$@" ]; then
    cd "$@" && ls -lrthG
  else
    echo "$@" directory not found!!!
  fi
}

# push to all repos recursively
gpa()
{
  if [ "$#" = 0 ]; then
    for dir in $(find . -name ".git"); do cd ${dir%/*}; git pull ; cd -; done
  else
    for dir in $(find $@ -name ".git"); do cd ${dir%/*}; git pull ; cd -; done
  fi
}



# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# faster rubocop as per https://dev.to/doctolib/make-rubocop-20x-faster-in-5-min-4pjo
export PATH="/usr/local/bin/rubocop-daemon-wrapper:$PATH"

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh


# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"
eval `dircolors ~/.dir_colors/dircolors`

# load custom executable functions
for function in ~/code/dotfiles/zsh/functions/*; do
	source $function
done


# # extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# # these are loaded first, second, and third, respectively.
# _load_settings() {
# 	_dir="$1"
# 	if [ -d "$_dir" ]; then
# 		if [ -d "$_dir/pre" ]; then
# 			for config in "$_dir"/pre/**/*(N-.); do
# 				. $config
# 			done
# 		fi
# 		for config in "$_dir"/**/*(N-.); do
# 			case "$config" in
# 				"$_dir"/pre/*)
# 					:
# 					;;
# 				"$_dir"/post/*)
# 					:
# 					;;
# 				*)
# 					if [ -f $config ]; then
# 						. $config
# 					fi
# 					;;
# 			esac
# 		done
# 		if [ -d "$_dir/post" ]; then
# 			for config in "$_dir"/post/**/*(N-.); do
# 				. $config
# 			done
# 		fi
# 	fi
# }
# _load_settings "$HOME/code/dotfiles/zsh/configs"

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Add this to your zshrc or bzshrc file
_not_inside_tmux() { [[ -z "$TMUX" ]] }

ensure_tmux_is_running() {
	if _not_inside_tmux; then
		tat
	fi
}

ensure_tmux_is_running


# No arguments: `git status`
# With arguments: acts like `git`
# g() {
#   if [[ $# > 0 ]]; then
#     git $@
#   else
#     git status -v
#   fi
# }


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

  
# Add composer 
export PATH="$PATH:$HOME/.composer/vendor/bin/"


# add cuda path for mxnet 
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH

setopt auto_cd
cdpath=($HOME/code $HOME/Documents)

plugins=(git zsh-syntax-highlighting zsh-autosuggestions jsontools docker history git-flow brew fasd rake ruby rails)

source $ZSH/oh-my-zsh.sh

# Complete g like git
compdef g=git

# User configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE

setopt no_list_beep
setopt no_beep


# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code -w'
fi


# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.


# add path to miniconda
export PATH=~/miniconda3/bin:$PATH

export PATH="$HOME/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/tcl-tk/bin:$PATH"


# fix error in eb ( aws ) 
export DYLD_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_LIBRARY_PATH


pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# export LUA_PATH='/home/mumu/.luarocks/share/lua/5.1/?.lua;/home/mumu/.luarocks/share/lua/5.1/?/init.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;./?.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?/init.lua'
# export LUA_CPATH='/home/mumu/.luarocks/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/?.so;./?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'

# necessary for asdf autocomplete
autoload bashcompinit
bashcompinit
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


if [ -f "$HOME/.laptop.local" ]; then
  fancy_echo "Running your customizations from ~/.laptop.local ..."
  # shellcheck disable=SC1090
  . "$HOME/.laptop.local"
fi

# recommended by brew doctor
export PATH=/usr/local/bin:$PATH


## MAC only 
# . $(brew --prefix asdf)/asdf.sh
# . $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash


export LANG=en_US.UTF-8


# TODO: TEMP # removing this as it is giving too many errors
# export RUBYOPT='-W:no-deprecated -W:no-experimental'


# Adding these because of asdf 
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

# mkdir .git/safe in the root of repositories you trust
export PATH=".git/safe/../../bin:$PATH"

## RUBY config
eval "$(rbenv init - --no-rehash)"
export PATH="$HOME/.rbenv/bin:$PATH"
# export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting


export PAT=799f32b1f0b47ae06019c9067bf288a115178a94
export PATH="$HOME/.poetry/bin:$PATH"
