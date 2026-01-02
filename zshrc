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
    for dir in $(find . -name ".git"); do cd ${dir%/*}; git push ; cd -; done
  else
    for dir in $(find $@ -name ".git"); do cd ${dir%/*}; git push ; cd -; done
  fi
}

deploy_ff() 
{
  gpa .. && b && g add Gemfile* && g ci -m "Update gems" && g push && g push heroku main && heroku run rake db:migrate -r heroku
}  

path_append() {
    if ! [[ ":$PATH:" == *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

#
# Usage :
# $> rna myapp 7.0.0 --minimal --database=postgresql
#
rna ()
{  
  # create dir, dive into dir, require desired Rails version
  mkdir -p -- "$1" && cd -P -- "$1"
  echo "source 'https://rubygems.org'" > Gemfile
  echo "gem 'rails', '$2'" >> Gemfile
 
  # install rails, create new rails app
  bundle install
  bundle exec rails new . --force ${@:3:99}
  bundle update

  # Create a default controller
  echo "class HomeController < ApplicationController" > app/controllers/home_controller.rb
  echo "end" >> app/controllers/home_controller.rb

  # Create a default route
  echo "Rails.application.routes.draw do" > config/routes.rb
  echo '  get "home/index"' >> config/routes.rb
  echo '  root to: "home#index"' >> config/routes.rb
  echo 'end' >> config/routes.rb

  # Create a default view
  mkdir app/views/home
  echo '<h1>This is h1 title</h1>' > app/views/home/index.html.erb

  # Create database and schema.rb
  bin/rails db:create
  bin/rails db:migrate
}

# faster rubocop as per https://dev.to/doctolib/make-rubocop-20x-faster-in-5-min-4pjo
path_append "/usr/local/bin/rubocop-daemon-wrapper"

# If you come from bash you might have to change your $PATH.
path_append $HOME/bin:/usr/local/bin

# nim
# export PATH=/home/murilo/.nimble/bin:$PATH

# faster rubocop as per https://dev.to/doctolib/make-rubocop-20x-faster-in-5-min-4pjo
export PATH="/usr/local/bin/rubocop-daemon-wrapper:$PATH"
export RUBOCOP_DAEMON_USE_BUNDLER=true

# node options to avoid tailwind breaking
export NODE_OPTIONS="--max-old-space-size=4096"


# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh


# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"
# eval `dircolors ~/.dir_colors/dircolors`
eval "$(dircolors -b ~/.dir_colors)"


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
_not_inside_tmux() { [[ -z "$TMUX" ]]; }
_is_not_vscode() { 
  [[ -z "$VSCODE_PID" ]] && [[ -z "$VSCODE_INJECTION" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]
}

ensure_tmux_is_running() {
	if _not_inside_tmux && _is_not_vscode; then
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
# path_append "$HOME/.composer/vendor/bin/"


# add cuda path for mxnet 
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH

setopt auto_cd
cdpath=($HOME/code $HOME/Documents)

plugins=(
  git 
  jsontools 
  docker 
  history 
  git-flow 
  brew 
  fasd 
  rake 
  ruby 
  rails 
  web-search
  extract
  sudo 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  )


source $ZSH/oh-my-zsh.sh
source "$HOME/.cargo/env"

# Complete g like git
compdef g=git

# User configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE

setopt no_list_beep
setopt no_beep


# export MANPATH="/usr/local/man:$MANPATH"

# allow 4 GB of memory for node
export NODE_OPTIONS=--max-old-space-size=4096

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
path_append ~/miniconda3/bin


path_append "$HOME/.bin"
path_append "/usr/local/sbin"

# rust
path_append "$HOME/.cargo/bin"
path_append "/usr/local/opt/tcl-tk/bin"
# GO
path_append "/usr/local/go/bin"
path_append "$HOME/go/bin"

# GO
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/go/bin:$PATH:

# PHP
# export PATH="$HOME/.config/composer/vendor/bin:$PATH"

path_append "$HOME/code/dotfiles/bash_scripts"
# path_append 

# fix error in eb ( aws ) 
# export DYLD_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_LIBRARY_PATH


cleandisk() {
  echo "Cleaning up disk space..."
  sudo apt-get clean
  sudo apt-get autoclean
  sudo apt-get autoremove
  
  sudo rm -rf /var/cuda-repo-ubuntu2204-12-8-local
  sudo rm /etc/apt/sources.list.d/cuda-ubuntu2204-12-8-local.list

  rm -rf ~/.cache/solargraph
  rm -rf ~/.cache/ms-playwright

  echo "Cleaning PYTHON cache..."
  
  uv cache clean
  poetry cache clear PyPI --all
  pip cache purge

  echo "Disk cleanup complete."
}

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


# necessary for asdf autocomplete
autoload bashcompinit
bashcompinit
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


if [ -f "$HOME/.laptop.local" ]; then
  fancy_echo "Running your customizations from ~/.laptop.local ..."
  # shellcheck disable=SC1090
  . "$HOME/.laptop.local"
fi


## fabric config https://github.com/danielmiessler/fabric
# Loop through all files in the ~/.config/fabric/patterns directory
# for pattern_file in $HOME/.config/fabric/patterns/*; do
#     # Get the base name of the file (i.e., remove the directory path)
#     pattern_name=$(basename "$pattern_file")

#     # Create an alias in the form: alias pattern_name="fabric --pattern pattern_name"
#     alias_command="alias $pattern_name='fabric --pattern $pattern_name'"

#     # Evaluate the alias command to add it to the current shell
#     eval "$alias_command"
# done

yt() {
    local video_link="$1"
    fabric -y "$video_link" --transcript
}

# recommended by brew doctor
path_append /usr/local/bin

## MAC only 
# . $(brew --prefix asdf)/asdf.sh
# . $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash


export LANG=en_US.UTF-8


# TODO: TEMP # removing this as it is giving too many errors
# export RUBYOPT='-W:no-deprecated -W:no-experimental'


# Adding these because of asdf 
export PATH=$PATH:~/.local/bin
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
# export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
# export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

# mkdir .git/safe in the root of repositories you trust
export PATH=".git/safe/../../bin:$PATH"

## RUBY config
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - --no-rehash)"
# export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting


source ~/code/dotfiles/private_vars.sh

export PATH="$HOME/.poetry/bin:$PATH"
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/murilo/code/aio/google-cloud-sdk/path.zsh.inc' ]; then . '/home/murilo/code/aio/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/murilo/code/aio/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/murilo/code/aio/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(/home/murilo/.local/bin/mise activate zsh)"
# export PATH="$PATH:/opt/mssql-tools/bin"


# disable crewai telemetry
export OTEL_SDK_DISABLED=true
export ANONYMIZED_TELEMETRY=false
export LANGCHAIN_TRACING_V2=false
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"


# path_append "$HOME/code/dotfiles/bash_scripts"
export PATH="$HOME/code/dotfiles/bash_scripts:$PATH"


export PATH="$HOME/.pyenv/bin:$PATH"


# AI related 

export ANTHROPIC_MODEL='global.anthropic.claude-sonnet-4-5-20250929-v1:0'
export ANTHROPIC_SMALL_FAST_MODEL='global.anthropic.claude-haiku-4-5-20251001-v1:0'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='global.anthropic.claude-haiku-4-5-20251001-v1:0'


eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo_green() {
  fancy_echo "\033[1;32m$1\033[0m"
}
echo_red() {
  fancy_echo "\033[1;31m$1\033[0m"
}

echo_yellow() {
  fancy_echo "\033[1;33m$1\033[0m"
}

echo_green "✔ ZSH configuration loaded successfully!"

# eval "$(starship init zsh)"
export WATCHMAN_ACCEPT_NICE_VALUE=1
