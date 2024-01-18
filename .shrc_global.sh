# .shrc
# vim: set syntax=sh:
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# This might not pull in from profile.sh if it isn't sourced as part of the same shell session. Just redefine it here.
source_files ()
{
  for _file_path in "$@"; do
    if [ -f "${_file_path}" ]; then
        . "${_file_path}"
    fi
  done
  _file_path=;
}

# Automatically start TMUX for interactive terminals
# See info here: https://wiki.archlinux.org/index.php/Tmux#Start_tmux_on_every_shell_login
if [ -z "$TMUX" ] && [ -n "${AUTO_RUN_TMUX_ARGS}" ] && type tmux >/dev/null 2>&1; then
    # see answer here: https://unix.stackexchange.com/a/26827/28898
    case $- in
      *i*) tmux ${AUTO_RUN_TMUX_ARGS};;
      *) ;;
    esac
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
    elif `which gcc >/dev/null 2>&1`;
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

    # grep removes all blank and commented out lines
    # sed grabs all variable names and ignores variable values
    unset $(grep -vE '^#|^$' "$filename" | sed -E 's/([^=]+)=.*/\1/' | xargs -0)
}

_git_print_branch ()
{
    if git rev-parse --absolute-git-dir >/dev/null 2>&1; then
        echo " (git: $(git symbolic-ref --short HEAD 2>/dev/null || echo 'HEAD detached at' $(git rev-parse --short HEAD)))"
    fi
}

_tmux_new_session_group ()
{
    # This is mostly for reference. Something similar is used in VS Code
    # settings.json file for internal terminal windows.
    tmux new-session -c "$(pwd)" -t main ';' new-window -c "$(pwd)";
}

_tmux_print_status ()
{
    if [ -n "$TMUX" ]; then
        # echo '(tmux:' $(tmux display-message -p "#{session_name}") "pane: ${TMUX_PANE})"
        tmux display-message -p ' (tmux: #{session_name} #{window_id})';
    fi
}

tmux_iterm2 ()
{
    tmux -CC new -A -s "$1"
}

ssh_tmux_iterm2 ()
{
    ssh -t "$1" "tmux -CC new -A -s '$1'"
}

ssh_tmux ()
{
    ssh -t "$1" "tmux new -A -s '$1'"
}

display_notification ()
{
    message=$1
    title=$2
    subtitle=$3

    # Different per system
    if [ $(uname -s) = "Darwin" ]; then
        osascript - "$@" <<EOF
on run argv
    if length of argv = 1 then
        display notification (item 1 of argv) with title "Notification"
    else if length of argv = 2 then
        display notification (item 1 of argv) with title (item 2 of argv)
    else if length of argv = 3 then
        display notification (item 1 of argv) with title (item 2 of argv) subtitle (item 3 of argv)
    else
        return "<message> is required\nUsage: notify <message> [<title>]"
    end if
end run
EOF
    # elif [ $(uname -s) = "FreeBSD" ]; then
    #     osascript -e "display notification \"message\" with title \"title\" subtitle \"subtitle\""
    else
        echo "Cannot display UI notification on current system configuration" >&2
        return 1
    fi
}

# Functions to run
setaliases
_canonical_home

# Custom terminal prompt sans color
PS1="[\$(whoami)@\h \W]"
PS1="${PS1}\$(_tmux_print_status)"
PS1="${PS1}\$(_git_print_branch)"

# Trailing character of PS1 determined on whether we are currently root or not
case `id -u` in
    0) PS1="${PS1}# ";;
    *) PS1="${PS1}$ ";;
esac

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Load RVM into a shell session *as a function*
[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"

# Print if any brew package upgrades are available.
if [ -n "${CHECK_HOMEBREW_OUTDATED}" ] && type brew >/dev/null 2>&1
then
  brew outdated
fi

# source local shell overrides and additions
source_files "${HOME}/.shrc_local" "${HOME}/.shrc_local.sh" "${HOME}/.shrc-local.sh"
