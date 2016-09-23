
ln -s ~/code/dotfiles/zshrc ~/.zshrc
ln -s ~/code/dotfiles/vimrc ~/.vimrc
ln -s ~/code/dotfiles/tmux.conf ~/.tmux.conf

sudo cp -rp /bin/* /usr/local/bin/

# tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Unix
alias ll="ls -al"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e="$EDITOR"
alias v="$VISUAL"

# Bundler
alias b="bundle"

# Rails
alias migrate="rake db:migrate db:rollback && rake db:migrate db:test:prepare"
alias s="rspec"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

alias gdel='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias gdelr="git fetch -p origin && git branch -r --merged | grep origin |grep -v '>' | grep -v develop | xargs -L1 | cut -d"/" -f2- | xargs git push origin --delete"
# Include custom aliases
[[ -f ~/.aliases.local ]] && source ~/.aliases.local


chsh -s $(which zsh)

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

##### GIT configurations

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage "reset HEAD"
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.brs "for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'"
git config --global alias.glog 'log -E -i --grep'
git config --global alias.car 'commit --amend --no-edit'
git config --global alias.uncommit 'reset --soft HEAD^'


git config --global diff.tool vimdiff
git config --global merge.tool vimdiff
git config --global difftool.prompt false

git config --global merge.tool diffmerge

