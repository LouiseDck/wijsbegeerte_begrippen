#!/bin/bash
set -e
NEWLINE=$'\n'

sysread() {
	# add a . to preserve the trailing newlines
	REPLY=$(dd bs=8192 count=1 2> /dev/null; echo .)
	REPLY=${REPLY%?} # strip the .
	[ -n "$REPLY" ]
}

nl=''

case "$1" in
"")
	while ls * 1> /dev/null 2>&1; do
		# Takes care of files with spaces
		readarray -t files <<<"$(ls | shuf)"
		for CARD in "${files[@]}"; do
			read -p "$CARD"
			cat "$CARD"
			read -p "Got it? [Y/n] " -n 1 ANS
			echo
			if [ "$ANS" != "n" ] && [ "$ANS" != "N" ]; then
				mv "$CARD" ".$CARD"
			fi
		done;
	done;;
write)
	while true; do
		read -p "${NEWLINE}Prompt: " PROMPT

		# Read in answer. Allows for newlines & backspaces
		answer=""
		finished=false
		while ! "$finished" && sysread; do
		  case $REPLY in
		    (*"$nl") line=${REPLY%?};; # strip the newline
		    (*) line=$REPLY finished=true
		  esac

		  answer=${answer}${NEWLINE}${line}
		done

		echo "$answer" > "$PROMPT"
	done;;
learn)
	shift
	for F in $@; do
		mv "$F" ".$F"
	done;;
forget)
	shift
        for F in $@ .[^.]*; do
                if [[ $F == .* ]];then
                        mv "$F" "${F:1}"
                fi
	done;;
*)
	CMD=`basename $0`
	echo "Usage:"
	echo "  $CMD"
	echo "  $CMD write"
	echo "  $CMD learn  <file...>"
	echo "  $CMD forget <file...>"
esac
