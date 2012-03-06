# .bashrc

#=============================================================================
# SOURCES
#=============================================================================
[ -f ${HOME}/.colors ] && source ${HOME}/.colors


#=============================================================================
# FUNCTIONS
#=============================================================================
screen_caption()
{
  CAPTION=`basename $PWD`
  echo -ne "\033k$(basename $PWD)\033\\"
}

parse_git_branch()
{
  BRANCH=`git branch 2>/dev/null | sed -n 's/^\* //p'`
  [ ! -z "$BRANCH" ] && echo -n " [$BRANCH]"
}

smart_co()
{
  echo $@
  if "git status 1>/dev/null 2>/dev/null"; then 
    git co $@
  else
    co $@
  fi
}


#=============================================================================
# ALIASES
#=============================================================================
alias homegit="git --git-dir=$HOME/.homegit --work-tree=$HOME"


#=============================================================================
# VARIABLES
#=============================================================================
export BLOCKSIZE=K;
export EDITOR=vim;
export PAGER=less;
export CLICOLOR="YES";
export LSCOLORS="ExGxFxdxCxDxDxhbadExEx";
export PATH=${PATH}:${HOME}/local/bin


#=============================================================================
# PROMPT AND SCREEN
#=============================================================================
export PS1="\${debian_chroot:+($debian_chroot)}\u@\h:\[$TXTGRN\]\w\[$TXTYLW\]\$(parse_git_branch)\[$TXTRST\]\$ "
case "$TERM" in
screen)
    HOST=`hostname | sed 's/\..*//'`
    #PROMPT_COMMAND='echo -ne "\033k$HOST\033\\"'
    ;;
esac
export GEM_HOME=/shadow/home/marut/gems
export GEM_PATH=/shadow/home/marut/gems:/usr/lib/ruby/gems/1.8/
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/shadow/home/marut/bin:/shadow/home/marut/local/bin:/local/sbin:/cat/bin:/shadow/home/marut/gems/bin
