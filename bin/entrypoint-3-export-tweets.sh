#!/bin/bash
#
# Script to run our tweet analysis script.
#


NUM=${NUM:=5}
ARGS=""

if test "$LOOP_SECONDS"
then
	ARGS="${ARGS} --loop ${LOOP_SECONDS}"
fi

if test "$FORCE"
then
	ARGS="${ARGS} --force"
fi

STDOUT=logs/3-tweet-export.log
STDERR=logs/3-tweet-export.stderr

#
# If we're in debug mode, write to stdout.  This is useful for development.
#
if test "$DEBUG"
then
	echo "##### DEBUG MODE ENABLED: Writing to stdout and stderr!"
	STDOUT=/dev/stdout
	STDERR=/dev/stderr
fi

echo "# "
echo "# Starting Tweet analysis script"
echo "# "
echo "# Available env vars: NUM, LOOP_SECONDS, FORCE, DEBUG"
echo "# "
echo "# Number of tweets to export per loop: ${NUM}"
echo "# "

if test "$LOOP_SECONDS"
then
	echo "# Sleeping between loops for this many seconds: ${LOOP_SECONDS}"
	echo "# "
else
	echo "# Only running once, not looping. "
	echo "# "
fi

if test "$FORCE"
then
	echo "# We are forcing exports of all tweets"
	echo "# "
fi

if test "${ARGS}"
then
	echo "# Args: ${ARGS}"
	echo "# "
fi

echo "# "
echo "# "
echo "# Output will be written to: ${STDOUT}"
echo "# Stderr will be written to: ${STDERR}"
echo "# "

./bin/3-export-analyzed-tweets  --num ${NUM} ${ARGS} >> ${STDOUT} 2>> ${STDERR}


