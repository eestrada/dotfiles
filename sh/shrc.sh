# .shrc
# vim: set syntax=sh:
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# This might not pull in from profile.sh if it isn't sourced as part of the same shell session. Just redefine it here.
source_files ()
{
  for fpath in "$@"; do
    if [ -f "${fpath}" ]; then
        . "${fpath}"
    fi
  done
  fpath=;
}

# Use Base16 syntax highlighting, if available
BASE16_SHELL=$HOME/.base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)" && sleep 0.1

if [ "${TERM_PROGRAM}" '!=' "iTerm.app" ] && [ -z "${DONT_AUTO_RUN_TMUX}" ]; then
# Automatically start TMUX for interactive terminals
if which tmux >/dev/null 2>&1; then
    # See info here: https://wiki.archlinux.org/index.php/Tmux#Start_tmux_on_every_shell_login
    if [ -z "$TMUX" ] ; then
        # see answer here: https://unix.stackexchange.com/a/26827/28898
        case $- in
          *i*) tmux new-session && exit;;
          *) ;;
        esac
    fi
fi
fi

# Source global bashrc definitions
if [ "$(basename ${SHELL})" = 'bash' ] && [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
_canonical_home ()
{
    # NOTE: on FreeBSD, /home is actually just a symlink to /usr/home. Here we
    # detect this and get us back home... which is actually /home.
    if [ "$(pwd)" -ef "${HOME}" ] && [ "$(pwd)" '!=' "${HOME}" ]; then
        cd "${HOME}" >/dev/null;
    fi
}

dush ()
{
    du -d 1 -h "$@" | sort -h;
}

find_dupes_in_cwd ()
{
    find ./ -type f -print0 | xargs -0 sha256 | sort -k 4 | uniq -d -f 3
}

# Set any custom aliases
setaliases ()
{
    if [ $(uname -s) = "FreeBSD" ] || [ $(uname -s) = "Darwin" ]; then
        alias ls="ls -G";
        alias ll="ls -Gslh";
    else
        alias ls="ls --color=auto";
        alias ll="ls -slh";
    fi

    # User specific aliases
    if [ $(uname -s) = "FreeBSD" ]; then
        alias rm="rm -I";
    elif [ $(uname -s) = "Darwin" ]; then
        alias rm="rm -i";
    else
        alias rm="rm -I --preserve-root";
    fi

    # alias mv="mv -u";
    # alias cp="cp -u"; # This has caused me too many headaches
    alias mkdir="mkdir -v";
    alias dus="du --max-depth=1";
    alias gtar="tar --format=gnu";
    alias ustar="tar --format=ustar";
    alias ptar="tar --format=pax";

    # alias c++="${CXX} -std=c++98";
    # alias c99="${CC} -std=c99";
    # alias c89="${CC} -std=c89";
    #alias nospaces="rename -v \  _ ";

    # Do not create gvim swap files.
    alias gvimn="gvim -n -p";

    # Make diff print in an easier to read format by default
    alias diff='diff --unified=3';

    # I often forget the rsync flags I like for backups, so let's just
    # bake them into an alias. Ignore obvious temporary files.
    alias rsync-backup="rsync -vrlpEtgoDH --exclude '*~'";

    # Make colors work right in tmux, dagnabit!
    alias tmux='tmux -2';
}

# Cause tmux to have a "dirty" exit so that we fall back to a bare shell
# instead of exiting entirely from the terminal, which is the default on a
# clean tmux exit. Probably don't use this, as it exits not only the current
# client, but also kills the tmux server as well. :(
tmux_exit ()
{
    kill -s TERM $PPID
}

set_cc ()
{
    # Use clang if it exists, otherwise use gcc, otherwise use the system default
    if `which clang >/dev/null 2>&1`;
    then
        export CXX=clang++;
        export CC=clang;
        export CXXFLAGS="-pedantic -Wall";
        export CFLAGS="-pedantic -Wall";
    elif `which gcc  >/dev/null 2>&1`;
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


# Set up any Houdini specific env

# Function for general initialization of Houdini
hfsinit ()
{
    if [ -d "${HFS}" ]; then
        cd ${HFS};
        . ./houdini_setup;
        cd - > /dev/null;
        # Modifying PYTHONPATH causes issues when switching Houdini versions
        #export PYTHONPATH=${PYTHONPATH}:${HH}/python2.6libs;
    fi
}

hcurrent ()
{
    export HFS="/opt/hfs.current";
    hfsinit;
}

h130init ()
{
    export HFS="/opt/hfs13.0.current";
    hfsinit;
}

h125init ()
{
    export HFS="/opt/hfs12.5.current";
    hfsinit;
}

h121init ()
{
    export HFS="/opt/hfs12.1.current";
    hfsinit;
}

h111init ()
{
    export HFS="/opt/hfs11.1.current";
    hfsinit;
}

set_job ()
{
    echo "Previous JOB was: ${JOB}" 1>&2
    export JOB=$(pwd);
    echo "Current JOB is: ${JOB}" 1>&2
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
    echo "Mash Ctrl-c within the next 10 seconds to cancel..."
    sleep 10
    echo "Do you want to proceed? (select your choice by number)"
    sudo ${plt_local} --in-place --dest ${dest} ${create_links}
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

beadm_update ()
{
    # Ideas for this code were inspired by: https://forums.FreeBSD.org/threads/freebsd-upgrade-with-beadm.53225/post-299112
    set -v
    local to_mount=$1

    sudo beadm mount "$to_mount" /mnt
    sudo mount -t devfs devfs /mnt/dev

    sudo chroot /mnt $SHELL

    sudo umount /mnt/dev
    sudo beadm umount "$to_mount"
    sudo beadm activate "$to_mount"
    set +v
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
    play -n synth 0.1 sin 880 2>/dev/null || print -n "\a";
}

rclone_sync_dropbox ()
{
    # NOTE: we use a 3 second window because FAT filesystems only have a 2 second resolution for modified datetimes
    rclone copy --verbose --update --modify-window='3s' --exclude='.st*/' "${HOME}/Syncthing/Main/" dropbox: ;
    rclone copy --verbose --update --modify-window='3s' --exclude='.st*/' dropbox: "${HOME}/Syncthing/Main/" ;
}

wlan_init ()
{
    # NOTE: for freebsd since for some reason loading this all at boot causes a
    # kernel panic or something and the machine fails to boot. :(

    # NOTE: after upgrading from FreeBSD 11.1 to 12.0 it now seems that the
    # proper kernal modules are automatically loaded on init now. However, link
    # aggregation is broken since the wlan0 device is not created and/or active
    # when link aggregation tries to add it... or something; I'm not 100%
    # certain why  it is failing yet, but that just seems like what it is from
    # the print outs from boot and init. Restarting netif is still required.
    # Not sure if restarting wpa_supplicant is necessary anymore (it doesn't
    # seem to be after the upgrade), but other than a few seconds of down time,
    # it doesn't seem to hurt anything.

    # NOTE: now that I dynamically load the correct kernal modules in rc.conf
    # (via kld_list) everything works. wlan, link aggregation, everything. None
    # of this code is really necessary anymore. I will keep it around for now
    # until I can test using wi-fi away from home just to make sure
    # wpa_supplicant is working as expected.

    # sudo kldload iwm3160fw if_iwm
    sudo service netif restart
    sleep 10
    sudo service wpa_supplicant restart wlan0
    # docker-machine restart
}

docker_machine_init ()
{
    docker-machine start
    docker-machine restart # NOTE: in case it was already running before
    eval $(docker-machine env)
    export DOCKER_MACHINE_IP_ADDRESS="$(docker-machine ip)"
}

# dotenv code originally from: https://stackoverflow.com/a/20909045/1733321
dotenv_src ()
{
    # Source and export environment variables from a dotenv file. Should work
    # in all bourne compatible shells.

    # If no file is given, default to '.env'
    if [ -n "$1" ]; then
        filename="$1"
    else
        filename=".env"
    fi

    # FIXME: change grep and xargs invocations if on *BSD or Darwin
    # grep removes all blank and commented out lines
    export $(grep -vE '^#|^$' "$filename" | xargs -0)
}

dotenv_unsrc ()
{
    # Unset any variable names found in a given dotenv file wihin the current
    # scope. Should work in all bourne compatible shells.

    # If no file is given, default to '.env'
    if [ -n "$1" ]; then
        filename="$1"
    else
        filename=".env"
    fi

    # FIXME: change grep and xargs invocations if on *BSD or Darwin
    # grep removes all blank and commented out lines
    # sed grabs all variable names and ignores variable values
    unset $(grep -vE '^#|^$' "$filename" | sed -E 's/([^=]+)=.*/\1/' | xargs -0)
}

interactive_vars ()
{
    # Terminal variables
    # Custom terminal prompt
    if [ "$(basename ${SHELL})" = 'bash' ]; then
        PS1="[\u@\h \W]"
    elif [ "$(basename ${SHELL})" = 'zsh' ]; then
        PS1='[%n@%m %~]'
    elif [ "$(basename ${SHELL})" = 'mksh' ]; then
        PS1='[$(echo -n "`logname`@`hostname`: " ; if [ "${PWD}" -ef "${HOME}" ] ; then echo -n "~" ; else echo -n "$(basename ${PWD})" ; fi ; echo "]")'
        export HISTFILE="$HOME/.mksh_history" && export HISTSIZE="32767"
    else
        # Assume /bin/sh or something compatible
        PS1="[$(whoami)@\h \W]"
    fi

    # Trailing character of PS1 determined on whether we are currently root or not
    case `id -u` in
        0) PS1="${PS1}# ";;
        *) PS1="${PS1}$ ";;
    esac
}

# final shell specific stuff
if [ "$(basename ${SHELL})" = 'bash' ]; then
    # update PATH for the Google Cloud SDK.
    source_files "${HOME}/google-cloud-sdk/path.bash.inc"

    # Use bash-completion, if available
    [ -n "$PS1" ] && source_files /usr/local/share/bash-completion/bash_completion \
                                  /usr/local/etc/profile.d/bash_completion.sh \
                                  "${HOME}/google-cloud-sdk/completion.bash.inc";
elif [ "$(basename ${SHELL})" = 'zsh' ]; then
  # # enable zsh terminal completions
  # FPATH="/usr/share/zsh/5.7.1/functions:${FPATH}"
  # export FPATH;
  #
  # autoload -Uz compinit && compinit
  #
  # # The following lines were auto-generated by compinstall
  #
  # zstyle ':completion:*' completer _complete _ignored
  # zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
  # zstyle :compinstall filename '/Users/eestrada/.zshrc'
  #
  # # End of lines added by compinstall
  echo "In zsh" > /dev/null;
fi

# Functions to run
setaliases
interactive_vars
_canonical_home

# source local shell overrides and additions
source_files "${HOME}/.shrc_local" "${HOME}/.shrc_local.sh" "${HOME}/.shrc-local.sh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Load RVM into a shell session *as a function*
[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"
