# Dotfiles 

## Installation

To install, you must do the following:

```cd
mkdir code
cd code 
g clone git@github.com:muriloime/dotfiles.git```

This will create a repo called dotfiles at ~/code/. Next you need to run: 

```sh fresh_start.sh```

Thiw will do the following: 
 * create a simbolic links to zshrc, vimrc, gitconfig, tmux.conf aliases files
 * copy tmux plugins, bin files to correspondent folder
 * install tpm ( tmux plugin manager) 
 * install vundle ( vim plugin manager) 
 * change default shell to zsh instead of bash 
 * install oh-my-zsh ( zshell helper, with plugin manager) 
 * define tons of aliases for git 
 * install pip (python) 
 * reload zshrc


