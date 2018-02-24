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
_canonical_home ()
{
    if [ "$(pwd)" -ef "${HOME}" ] && [ "$(pwd)" '!=' "${HOME}" ]; then
        cd "${HOME}";
    fi
}

# echo command, but to stderr instead of stdout
echoerr()
{
    echo "$@"  1>&2;
}

# NOTE: make `echoerr` available to subprocesses and sub-shells
export -f echoerr

_is_freebsd()
{
    if [ $(uname -s) = "FreeBSD" ]; then
        return 0
    else
        return 1
    fi
}

dush()
{
    du --max-depth=1 -h "$@" | sort -h;
}

# Set any custom aliases
setaliases()
{
    if $(_is_freebsd); then
        alias ls="ls -G";
        alias ll="ls -Gslh";
    else
        alias ls="ls --color=auto";
        alias ll="ls -slh";
    fi
    # User specific aliases
    if $(_is_freebsd); then
        alias rm="rm -I";
    else
        alias rm="rm -I --preserve-root";
    fi
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

    # Make diff nicer for interactive usage
    alias diff='diff --unified=3 --report-identical-files';

    # I often forget the rsync flags I like for backups, so let's just
    # bake them into an alias. Ignore obvious temporary files.
    alias rsync-backup="rsync -vrlpEtgoDH --exclude '*~'";

    # Make colors work right, dagnabit!
    alias tmux='tmux -2';
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
    if $(which vim >/dev/null 2>&1);
    then
        export EDITOR="vim";
    else
        export EDITOR="vi";
    fi

    if $(which vim >/dev/null 2>&1);
    then
        export VISUAL="vim";
    else
        export VISUAL=${EDITOR};
    fi

    export PAGER="less";
    export GPG_TTY="$(tty)";

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

    # Add default key
    ssh-add;
    # Add any private keys that have corresponding public keys
    cd ~;
    ssh-add $(ls .ssh/ | awk '/\.pub$/' | sed 's/^\(.*\)\.pub/.ssh\/\1/');
    cd -;
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

_ps_all ()
{
    if $(_is_freebsd); then
        ps -auxw;
    else
        ps -ef;
    fi
}

run_ssh ()
{
    # check for running ssh-agent with proper $SSH_AGENT_PID
    if [ -n "${SSH_AGENT_PID}" ]; then
        _ps_all | grep "${SSH_AGENT_PID}" | grep ssh-agent > /dev/null;
        if [ $? -eq 0 ]; then
        test_identities;
        fi
    # if ${SSH_AGENT_PID} is not properly set, we might be able to load one from
    # ${SSH_ENV}
    else
        if [ -f "${SSH_ENV}" ]; then
            . "${SSH_ENV}" > /dev/null;
        fi

        _ps_all | grep "${SSH_AGENT_PID}" | grep -v grep | grep ssh-agent > /dev/null;
        if [ $? -eq 0 ]; then
            test_identities;
        else
            start_agent;
        fi
    fi
}

racket_install ()
{
    if [ -z "$1" ]; then
        echo "No arguments given!";
        echo 'Need at least one argument.';
        echo 'First arguments indicates the version of Racket to install (e.g. "6.7", "6.8", etc.)';
        echo 'The second argument, if the string "false", will prevent the script from creating links after install';
        return 1
    fi

    plt_url="https://mirror.racket-lang.org/installers/${1}/racket-${1}-x86_64-linux.sh";
    plt_local="${TEMP}/racket-${1}-x86_64-linux.sh";
    dest="/usr/local/racket/$1";
    links="/usr/local";

    if [ "$2" = "false" ]; then
        create_links="";
    else
        create_links="--create-links ${links}";
    fi

    curl ${plt_url} > ${plt_local};
    chmod a+x ${plt_local};

    echo "We are about to execute the following command: 'sudo ${plt_local} --in-place --dest ${dest} ${create_links}'";
    echo "Do you want to proceed? (select your choice by number)"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo ${plt_local} --in-place --dest ${dest} ${create_links}; break;;
        No ) return 1;;
    esac
    done
}

racket_repl ()
{
    cd ${TEMP};
    racket;
}

racket_repl_exec ()
{
    cd ${TEMP};
    exec racket;
}

noise_gen ()
{
    # NOTE: command string originally sourced from this Stack Overflow
    # answer: https://askubuntu.com/a/789472/517979

    # NOTE: the `sox` package needs to be installed for the `play`
    # command to be available.
    play -n synth 1:0:0 brownnoise synth pinknoise mix synth sine amod 0.1 50;

    # TODO: add fade-in/fade-out. See answer here for details:
    # https://stackoverflow.com/a/24307805/1733321
    # TODO: control noise duration
    # TODO: control on/off via computer activity
    # TODO: make it loop (to save on CPU utilization). See Github Gist
    # here: https://gist.github.com/eestrada/f2808b95faaf24b5a7148a645e5b4545#file-noise-sh-L38

    # TODO: look into wrapping with `pysox`: https://github.com/rabitt/pysox
}

playbeep ()
{
    # NOTE: try to use the sox play utility. Failing that, send a
    # regular old terminal 'bel' character.
    play -n synth 0.1 sin 880 2>/dev/null || echo -ne "\a";
}

export -f playbeep

rclone-sync-dropbox ()
{
    rclone sync --verbose --update --delete-after ~/Dropbox/ dropbox: ;
    rclone sync --verbose --update --delete-after dropbox: ~/Dropbox/ ;
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
[ -n "$PS1" ] && [ -s "${HOME}/google-cloud-sdk/completion.bash.inc" ] && source "${HOME}/google-cloud-sdk/path.bash.inc";

# The next line enables shell command completion for gcloud.
[ -n "$PS1" ] && [ -s "${HOME}/google-cloud-sdk/completion.bash.inc" ] && source "${HOME}/google-cloud-sdk/completion.bash.inc";

# Use Base16 syntax highlighting, if available
BASE16_SHELL=$HOME/.base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)";

# Use bash-completion, if available
[ -n "$PS1" ] && [ -s /usr/local/share/bash-completion/bash_completion ] && . /usr/local/share/bash-completion/bash_completion;

_canonical_home
