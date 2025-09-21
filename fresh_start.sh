#!/bin/bash

#### Symbolic link for dotfiles

## only mac 
# ln -sfn ~/code/dotfiles/karabiner/karabiner.edn ~/.config/karabiner.edn
# ln -sfn ~/code/dotfiles/vscode-use\\r-setttings.json ~/Library/Application\ Support/Code/User/


chmod +x bash_scripts/*.py
chmod +x bash_scripts/*.sh

## only linux
ln -sfn ~/code/dotfiles/vscode-user-setttings.json ~/.config/Code/User/settings.json
sudo ln -sfn ~/code/dotfiles/hosts /etc/hosts 

# vim, zsh
ln -sfn ~/code/dotfiles/zshrc ~/.zshrc
ln -sfn ~/code/dotfiles/vimrc ~/.vimrc
ln -sfn ~/code/dotfiles/rgrc ~/.rgrc
ln -sfn ~/code/dotfiles/asdf ~/.asdf
ln -sfn ~/code/dotfiles/tmux.conf ~/.tmux.conf
ln -sfn ~/code/dotfiles/aider.conf.yml ~/.aider.conf.yml 

# rails
ln -sfn ~/code/dotfiles/pryrc ~/.pryrc
ln -sfn ~/code/dotfiles/irbrc ~/.irbrc
ln -sfn ~/code/dotfiles/gemrc ~/.gemrc
ln -sfn ~/code/dotfiles/railsrc ~/.railsrc
ln -sfn ~/code/dotfiles/rspecrc ~/.rspecrc
ln -sfn ~/code/dotfiles/aider.conf.yml ~/.aider.conf.yml
mkdir ~/.bundle
ln -sfn ~/code/dotfiles/bundle_config ~/.bundle/config

ln -sfn ~/code/dotfiles/psqlrc ~/.psqlrc

# espanso text expander 
ln -sfn ~/code/dotfiles/espanso_base.yml ~/.config/espanso/match/base.yml


# mise
mkdir -p ~/.config/mise
ln -sfn ~/code/dotfiles/dotfiles/mise.toml ~/.config/mise/config.toml

# llm 
mkdir -p "$(dirname "$(llm logs path)")/azure"
ln -sfn ~/code/dotfiles/dotfiles/llm-azure.yaml "$(dirname "$(llm logs path)")/azure/config.yaml"

### GIT
ln -sfn ~/code/dotfiles/gitconfig ~/.gitconfig
ln -sfn ~/code/dotfiles/gitignore_global ~/.gitignore_global
ln -sfn ~/code/dotfiles/bin/git-create-pull-request /usr/local/bin/git-create-pull-request

ln -sfn ~/code/dotfiles/aliases ~/.aliases

### CLAUDE
mkdir -p ~/.claude

ln -sfn ~/code/dotfiles/claude/hooks ~/.claude
ln -sfn ~/code/dotfiles/claude/commands ~/.claude
ln -sfn ~/code/dotfiles/claude/agents ~/.claude

sudo cp -rp bin/* /usr/local/bin/
chmod +x /usr/local/bin/git-*

cp -rp ipython/* ~/.ipython/

### tmux
sudo cp -rp tmux/* ~/.tmux/
chmod +x ~/.tmux/*.sh

# tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# vim plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

command -v zsh | sudo tee -a /etc/shells
chsh -s $(which zsh)

##### Oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

chsh -s $(which zsh)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

##### GIT configurations

ln -sfn ~/code/dotfiles/git_template ~/.git_template
git config --global init.templatedir '~/.git_template' 
# git config --global init.templatedir '~/code/dotfiles/git_template'
chmod a+x ~/code/dotfiles/git_template/hooks/*

git config --global alias.co checkout
git config --global merge.ff only
git config --global merge.conflictstyle diff3
git config --global push.default simple

git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage "reset HEAD"
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# git config --global alias.brs "for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'"
git config --global alias.glog 'log -E -i --grep'
git config --global alias.car 'commit --amend --no-edit'
git config --global alias.uncommit 'reset --soft HEAD^'


git config --global alias.aa "add --all"
git config --global alias.adp "add --patch"
git config --global alias.b "branch"
git config --global alias.ri "rebase -i"
git config --global alias.sdot "status . --short --branch"
git config --global alias.stat "show --stat"
git config --global alias.si "status --ignored"
git config --global alias.dc "diff --word-diff --cached --color-words"
git config --global alias.df "diff --word-diff --color-words"
git config --global alias.pl "pull"
git config --global alias.plr "pull --rebase"
git config --global alias.rim "!git rebase --interactive $(git merge-base master HEAD)"
git config --global alias.upstream "rev-parse --abbrev-ref --symbolic-full-name @{u}"
#git config --global alias.riu "!git rebase -i $(git upstream)"
git config --global alias.sl "log --oneline --decorate --graph -20"
git config --global alias.slap "log --oneline --decorate --all --graph"
git config --global alias.slp "log --oneline --decorate --graph"
git config --global alias.commend 'commit --amend --no-edit'
git config --global alias.it '!git init && git commit -m “root” --allow-empty'
git config --global alias.stsh 'stash --keep-index'
git config --global alias.staash 'stash --include-untracked'
git config --global alias.staaash 'stash --all'
git config --global alias.shorty 'status --short --branch'
git config --global alias.grog 'log --graph --abbrev-commit --decorate --all --format=format:"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)"'

git config --global alias.rim 'git config --global alias.plr "pull --rebase" rebase --interactive $(git merge-base master HEAD)"git config --global alias.riu "git config --global alias.plr "pull --rebase" rebase -i $(git upstream)"git config --global alias.sl "log --oneline --decorate --graph -20'


git config --global alias.po "push --set-upstream origin $(git branch | awk '/^\* / { print $2 }')"

git config --global alias.dd "branch --merged | egrep -v \"(^\*|master|develop)\" | xargs git branch -d"

git config --global alias.visual '!gitk'


git config --global push.default upstream
git config --global fetch.prune true


git config --global diff.tool vimdiff
git config --global merge.tool vimdiff
git config --global difftool.prompt false

git config --global merge.tool diffmerge



# generate certificates 
# load zshrc file
source ~/.zshrc
