#!/bin/bash
#
# Script to run our tweet fetching script.
#


STDOUT=logs/1-tweet-fetch.log
STDERR=logs/1-tweet-fetch.stderr
STRING=${STRING:=linux}
NUM=${NUM:=5}
ARGS=""

#
# If we're in debug mode, write to stdout.  This is useful for development.
#
if test "$DEBUG"
then
	echo "##### DEBUG MODE ENABLED: Writing to stdout and stderr!"
	STDOUT=/dev/stdout
	STDERR=/dev/stderr
fi

if test "$LOOP_SECONDS"
then
	ARGS="${ARGS} --loop ${LOOP_SECONDS}"
fi

if test "$RESULT_TYPE"
then
	ARGS="${ARGS} --result-type ${RESULT_TYPE}"
fi


echo "# "
echo "# Starting Tweet fetching script"
echo "# "
echo "# Available env vars: NUM, STRING, LOOP_SECONDS, RESULT_TYPE, DEBUG"
echo "# "
echo "# Search String: $STRING "
echo "# Number of tweets to fetch per loop: ${NUM}"
echo "# Extra args: ${ARGS}"
echo "# "
if test "$LOOP_SECONDS"
then
	echo "# Sleeping between loops for this many seconds: ${LOOP_SECONDS}"
else
	echo "# Only running once, not looping. "
fi
echo "# "
echo "# "
echo "# Output will be written to: ${STDOUT}"
echo "# Stderr will be written to: ${STDERR}"
echo "# "


./1-fetch-tweets --search ${STRING} --num ${NUM} ${ARGS} >> ${STDOUT} 2>> ${STDERR}


