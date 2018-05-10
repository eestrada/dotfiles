# $FreeBSD: releng/11.1/share/skel/dot.profile 278616 2015-02-12 05:35:00Z cperciva $
#
# .profile - Bourne Shell startup script for login shells
#
# see also sh(1), environ(7).
#

# These are normally set through /etc/login.conf.  You may override them here
# if wanted.
# PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin; export PATH
# BLOCKSIZE=K;	export BLOCKSIZE

# Setting TERM is normally done through /etc/ttys.  Do only override
# if you're sure that you'll never log in via telnet or xterm or a
# serial line.
# TERM=xterm; 	export TERM

# Source global definitions
if [ -f /etc/profile ]; then
    . /etc/profile
fi

export EDITOR="vi";
export PAGER="more";

# set ENV to a file invoked each time sh is started for interactive use.
if [ "$(basename ${SHELL})" = 'mksh' ]
then
    export ENV="$HOME/.mkshrc";
elif [ "$(basename ${SHELL})" = 'bash' ]
then
    export ENV="$HOME/.bashrc";
else
    export ENV="$HOME/.shrc";
fi

if [ -x /usr/bin/fortune ] ; then /usr/bin/fortune freebsd-tips && echo ; fi
