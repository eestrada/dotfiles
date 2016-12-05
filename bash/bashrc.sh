# .bashrc

# Emacs stuff
# Local Variables:
# mode: sh
# End:

# Source global definitions
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# User specific aliases and functions

# echo command, but to stderr instead of stdout
echoerr()
{
    echo "$@"  1>&2;
}

dush()
{
    du --max-depth=1 -h "$@" | sort -h;
}

# Set any custom aliases
setaliases()
{
    # User specific aliases
    alias ls="ls --color=auto";
    alias ll="ls -slh";
    alias rm="rm -I --preserve-root";
    #alias mv="mv -u";
    #alias cp="cp -u"; # This has caused me too many headaches
    alias mkdir="mkdir -v";
    alias dus="du --max-depth=1";
    alias gtar="tar --format=gnu";
    alias ustar="tar --format=ustar";
    alias ptar="tar --format=pax";
    alias tar="tar --format=pax";

    alias c++="${CXX} -std=c++98";
    alias c99="${CC} -std=c99";
    alias c89="${CC} -std=c89";
    #alias nospaces="rename -v \  _ ";

    # Do not create gvim swap files.
    alias gvimn="gvim -n -p";
}

# Set custom path. SYSPATH variable should exist
refreshpath()
{
    # Modify PATH now that env vars are set
    SYSPATH=${SYSPATH}:${PATH}
    PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games;
    PATH=${PATH}:/usr/local/sbin:/usr/local/bin:/usr/local/games;
    PATH=${PATH}:${HOME}/bin:${HOME}/usr/bin:${HOME}/usr/local/bin;
    PATH=${PATH}:${HOME}/.bin:${HOME}/.usr/bin:${HOME}/.usr/local/bin:${HOME}/.local/bin;
    PATH=${PATH}:/usr/local/cuda/bin:/usr/local/cuda-6.5/bin;
    PATH=${PATH}:${SYSPATH}

    # Remove duplicate entries
    IFS=:
    old_PATH=$PATH:; PATH=
    while [ -n "$old_PATH" ]; do
      x=${old_PATH%%:*}       # the first remaining entry
      case ${PATH}: in
        *:${x}:*) :;;         # already there
        *) PATH=$PATH:$x;;    # not there yet
      esac
      old_PATH=${old_PATH#*:}
    done
    PATH=${PATH#:}
    unset IFS old_PATH x

    export PATH;

    echoerr "Path has been refreshed.";
}


set_manpath()
{
    echoerr $MANPATH;
    oldman=$MANPATH;
    unset MANPATH;
    echoerr $(manpath);
    export MANPATH="$(manpath):~/.usr/local/share/man:$oldman";
    echoerr $MANPATH;
    unset oldman;
}

set_cc()
{
    # Use clang if it exists, otherwise use gcc, otherwise use the system default
    if `which clang &>/dev/null`;
    then
        export CXX=clang++;
        export CC=clang;
        export CXXFLAGS="-pedantic -Wall";
        export CFLAGS="-pedantic -Wall";
    elif `which gcc &>/dev/null`;
    then
        export CXX=g++;
        export CC=gcc;
        export CXXFLAGS="-pedantic -Wall";
        export CFLAGS="-pedantic -Wall";
    else
        export CXX=c++;
        export CC=cc;
        export CXXFLAGS="";
        export CFLAGS="";
    fi
}

# Set any custom variables
custvars()
{
    # Environment Variables to unset
    unset SSH_ASKPASS; # Don't pop up gui password window for SSH

    # Environment variables to declare
    export TEMP="/tmp";
    export VISUAL="gvim --nofork";
    if `which vim &>/dev/null`;
    then
        export EDITOR="vim";
    else
        export EDITOR="vi";
    fi
    export PAGER="less";

    # don't use set_cc by default
    # set_cc

    # Local variables
    PS1="[\u@\h \W]\$ "; # Custom terminal prompt
    SSH_ENV="${HOME}/.ssh/environment";    # Used to set up ssh environment

    echoerr "Environment variables customized.";
}

# Set up any Houdini specific env

# Function for general initialization of Houdini
hfsinit()
{
    if [ -d "${HFS}" ]; then
        cd ${HFS};
        source ./houdini_setup;
        cd - > /dev/null;
        # Modifying PYTHONPATH causes issues when switching Houdini versions
        #export PYTHONPATH=${PYTHONPATH}:${HH}/python2.6libs;
    fi
}

hcurrent()
{
    export HFS="/opt/hfs.current";
    hfsinit;
}

h130init()
{
    export HFS="/opt/hfs13.0.current";
    hfsinit;
}

h125init()
{
    export HFS="/opt/hfs12.5.current";
    hfsinit;
}

h121init()
{
    export HFS="/opt/hfs12.1.current";
    hfsinit;
}

h111init()
{
    export HFS="/opt/hfs11.1.current";
    hfsinit;
}

set_job()
{
    echoerr "Previous JOB was: ${JOB}"
    export JOB=$(pwd);
    echoerr "Current JOB is: ${JOB}"
}

# start the ssh-agent
start_agent()
{
    echoerr "Initializing new SSH agent...";
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}";
    echoerr "succeeded";
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null;
    ssh-add;
}

# test for identities
test_identities ()
{
    # test whether standard identities have been added to the agent already
    ssh-add -l | grep "The agent has no identities" > /dev/null;
    if [ $? -eq 0 ]; then
        ssh-add
        # ${SSH_AUTH_SOCK} broken so we start a new proper agent
        if [ $? -eq 2 ];then
            start_agent
        fi
    fi
}

run_ssh ()
{
    # check for running ssh-agent with proper $SSH_AGENT_PID
    if [ -n "${SSH_AGENT_PID}" ]; then
        ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent > /dev/null;
        if [ $? -eq 0 ]; then
        test_identities;
        fi
    # if ${SSH_AGENT_PID} is not properly set, we might be able to load one from
    # ${SSH_ENV}
    else
        if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null;
        fi
        ps -ef | grep "${SSH_AGENT_PID}" | grep -v grep | grep ssh-agent > /dev/null;
        if [ $? -eq 0 ]; then
            test_identities;
        else
            start_agent;
        fi
    fi
}

# Source local scripts
if [ -e "${HOME}/.bashrc_local" ]; then
    source ~/.bashrc_local;
fi

if [ -e "${HOME}/.bashrc_local.sh" ]; then
    source ~/.bashrc_local.sh;
fi

if [ -e "${HOME}/.bashrc-local.sh" ]; then
    source ~/.bashrc-local.sh;
fi

# Functions to run
custvars
setaliases

run_ssh
refreshpath

# The next line updates PATH for the Google Cloud SDK.
source "${HOME}/google-cloud-sdk/path.bash.inc";

# The next line enables shell command completion for gcloud.
source "${HOME}/google-cloud-sdk/completion.bash.inc";
