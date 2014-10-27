#!/usr/bin/zsh

#=============================================================================
# ENVIRONMENT-SPECIFIC STUFF
#=============================================================================
#[ -e "/pkgs/pkgs/PKGSsh" ] && . "/pkgs/pkgs/PKGSsh"

#=============================================================================
# SANITIZATION
#=============================================================================
[ -d "$HOME/.zsh" ] || mkdir "$HOME/.zsh"


#=============================================================================
# ZSH OPTIONS
#=============================================================================

setopt prompt_subst
setopt transient_rprompt
setopt appendhistory

autoload -Uz vcs_info
autoload -U compinit; compinit
autoload colors; colors

bindkey -v
bindkey '' history-incremental-search-backward

typeset -ga chpwd_functions
typeset -ga precmd_functions
typeset -ga preexec_functions


#=============================================================================
# VARIABLES
#=============================================================================

# set some colors
for COLOR in RED GREEN BLUE YELLOW WHITE BLACK CYAN; do
    eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'
    eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done

PR_RST="%{${reset_color}%}"
PR_RESET="%{%b%s%u$reset_color%}"
PR_BG="%{%(?.$PR_RESET.%S)%}"

CAPTION=`hostname | sed 's/\..*//'`

export HISTFILE=$HOME/.zsh/history
export HISTSIZE=1000
export SAVEHIST=10000
export BLOCKSIZE=K
export EDITOR=vim
export PAGER=less
export CLICOLOR="YES"
export LSCOLORS="ExGxFxdxCxDxDxhbadExEx"
export ENVPUPPET_BASEDIR=$HOME/repos
export RUBYLIB=$HOME/.puppet/modules/stack_builder/lib:$RUBYLIB
export RUBYLIB=$HOME/.puppet/modules/cloud_provisioner/lib:$RUBYLIB
export RUBYLIB=$HOME/.puppet/modules/cloud_provisioner_vmware/lib:$RUBYLIB
export VAGRANT_DEFAULT_PROVIDER=virtualbox
#source $HOME/.rvm/scripts/rvm


#=============================================================================
# ALIASES
#=============================================================================
[ `uname` = "Linux" ] && alias ls='ls --color'
alias vagrant="vagrant_suppress_expected_warnings"
alias puppet="puppet_suppress_iconv_warnings"
alias tmux="tmux -2"


#=============================================================================
# FUNCTIONS
#=============================================================================
function vagrant_suppress_expected_warnings {
  if [ "$1" = "sandbox" ]; then
    shift 1
    { \vagrant "$@" 2>&1 >&3 | egrep -v \
      -e 'Check your GSSAPI C librar' \
      -e 'WARNING: Nokogiri was built against LibXML version 2.8.0' \
      >&2
    } 3>&1 | { egrep -v \
      -e 'Invalid machine state: PoweredOff' \
      -e 'code VBOX_E_INVALID_VM_STATE (0x80bb0002),' \
      -e 'PowerDown(progress.asOutParam())" at line 224'
    }
  else
    { \vagrant "$@" 2>&1 >&3 | egrep -v \
      -e 'Check your GSSAPI C librar' \
      -e 'WARNING: Nokogiri was built against LibXML version 2.8.0' \
      >&2
    } 3>&1
  fi
}

function puppet_suppress_iconv_warnings {
  { \puppet "$@" 2>&1 >&3 | egrep -v 'iconv will be deprecated' >&2; } 3>&1
}


#=============================================================================
# PATH
#=============================================================================
PATH=/usr/local/bin:$PATH
PATH=$PATH:$HOME/local/bin:/local/sbin       # Add local bindirs
PATH=$PATH:/cat/bin                          # CAT environment bindir
PATH=$PATH:$HOME/local/lib/ruby/gems/1.8/bin # Local rubygem bindir
PATH=$PATH:$HOME/google-cloud-sdk/bin        # Google Cloud SDK


#=============================================================================
# GIT
#=============================================================================

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stangedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
FMT_BRANCH="${PR_GREEN}%b%u%c${PR_RST}" # e.g. master
FMT_ACTION="(${PR_CYAN}%a${PR_RST}%)"   # e.g. (rebase-i)
FMT_PATH="%R${PR_YELLOW}/%S"            # e.g. ~/repo/subdir

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*:prompt:*' check-for-changes true
zstyle ':vcs_info:*:prompt:*' unstagedstr   '?'  # display ? if there are unstaged changes
zstyle ':vcs_info:*:prompt:*' stagedstr     '!'  # display ! if there are staged changes
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"  "${FMT_PATH}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"               "${FMT_PATH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""                             "%~"

# called before command excution
# here we decide if we should update the prompt next time
function zsh_git_prompt_preexec {
  case "$(history $HISTCMD)" in
    *git*)
      PR_GIT_UPDATE=1
      ;;
  esac
}

# called after directory change
# we just assume that we have to update git prompt
function zsh_git_prompt_chpwd {
  PR_GIT_UPDATE=1
}

# called before prompt generation
# if needed, we will update the prompt info
function zsh_git_prompt_precmd {
  if [[ -n "$PR_GIT_UPDATE" ]] ; then
    vcs_info 'prompt'
    PR_GIT_UPDATE=
  fi
}

# update the vcs_info_msg_ magic variables, but only as little as possible
# This variable dictates weather we are going to do the git prompt update
# before printing the next prompt.  On some setups this saves 10s of work.
PR_GIT_UPDATE=1

preexec_functions+='zsh_git_prompt_preexec'
chpwd_functions+='zsh_git_prompt_chpwd'
precmd_functions+='zsh_git_prompt_precmd'

#=============================================================================
# VI NORMAL/INSERT MODE CHANGE
#=============================================================================

PR_VIMODE="#"
PR_VICOLOR=${PR_BLUE}
function zle-line-init zle-keymap-select {
  PR_VIMODE="${${KEYMAP/vicmd/¢}/(main|viins)/%%}"
  PR_VICOLOR="${${KEYMAP/vicmd/${PR_RED}}/(main|viins)/${PR_GREEN}}"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select


#=============================================================================
# PROMPT
#=============================================================================

function rprompt {
    local brackets=$1
    local color1=$2
    local color2=$3

    local git='${vcs_info_msg_0_}'

    local bracket_open="${color1}${brackets[1]}${PR_RESET}"
    local bracket_close="${color1}${brackets[2]}${PR_RESET}"

    RPROMPT="${bracket_open}${git}${bracket_close}"
}

function lprompt {
    local brackets=$1
    local color1=$2
    local color2=$3

    local bracket_open="${color1}${brackets[1]}${PR_RESET}"
    local bracket_close="${color1}${brackets[2]}${PR_RESET}"
    local colon="${color1}:${PR_RESET}"
    local at="${color1}@${PR_RESET}"

    local user_host="${color2}%n${at}${color2}%m${PR_RESET}"
    local vcs_cwd='${${vcs_info_msg_1_%%.}/$HOME/~}'
    local cwd="${color2}%B%40<..<${vcs_cwd}%<<%b${PR_RESET}"
    local inner="${user_host}${colon}${cwd}"

    local vimode='${PR_VIMODE}'
    local vicol='${PR_VICOLOR}'

    PROMPT="${bracket_open}${inner}${bracket_close}${PR_RESET} ${vicol}${vimode}${PR_RESET} "
}

function zsh_prompt_set_rprompt {
  if [ ! -z "${vcs_info_msg_0_}" ] ; then
    rprompt '()' $PR_BRIGHT_WHITE $PR_WHITE
  else
    rprompt '  ' $PR_BRIGHT_WHITE $PR_WHITE
  fi
}

function screen_caption() { 
  echo -ne "\033k$CAPTION\033\\"
}

precmd_functions+='zsh_prompt_set_rprompt'
[ "$TERM" = "screen" ] && precmd_functions+='screen_caption'

lprompt '[]' $PR_BRIGHT_WHITE $PR_WHITE
zsh_prompt_set_rprompt

# RVM
[ -e "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm"
