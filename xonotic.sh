#!/bin/sh
##
# A hackish way to get Xonotic running from a non-official build.
#

cd "/app/xonotic"

set -e
# Force 'run' param.
set -- "run" "$@"
echo "Params are: $@"

ECHO=echo

# I use this in EVERY shell script ;)
LF="
"
ESC=""

d00=`pwd`
d0=`pwd`
SELF="$d0/all"

msg()
{
	$ECHO >&2 "$ESC""[1m$*$ESC""[m"
}

verbose()
{
	msg "+ $*"
	"$@"
}

yesno()
{
	yesno=
	while [ x"$yesno" != x"y" -a x"$yesno" != x"n" ]; do
		eval "$2"
		$ECHO "$1"
		if ! IFS= read -r yesno; then
			yesno=n
			break
		fi
	done
	[ x"$yesno" = x"y" ]
}

cmd=$1
shift

# project config
. "$d0/misc/tools/all/config.subr"

# shared commands
handled=false

# Run the game
. "$d0/misc/tools/all/xonotic.subr" "$@"
