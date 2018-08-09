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

if test "$FAKE"
then
	ARGS="${ARGS} --fake"
fi


STDOUT=logs/2-tweet-analyze.log
STDERR=logs/2-tweet-analyze.stderr

#
# If we're in debug mode, write to stdout.  This is useful for development.
#
if test "$DEBUG"
then
	echo "##### DEBUG MODE ENABLED: Writing to stdout and stderr!"
	STDOUT=/dev/stdout
	STDERR=/dev/stderr
fi


AWS_CREDS=$HOME/.aws/credentials
if test ! -f $AWS_CREDS
then
	echo "! "
	echo "! AWS Credentials not found in $AWS_CREDS!  Stopping."
	echo "! "
	exit 1
fi

echo "# "
echo "# Starting Tweet analysis script"
echo "# "
echo "# Available env vars: NUM, LOOP_SECONDS, FAKE"
echo "# "
echo "# Number of tweets to analyze per loop: ${NUM}"
echo "# "

if test "$LOOP_SECONDS"
then
	echo "# Sleeping between loops for this many seconds: ${LOOP_SECONDS}"
	echo "# "
else
	echo "# Only running once, not looping. "
	echo "# "
fi

if test "$FAKE"
then
	echo "# We are faking calls to AWS so as not to run up our bill."
	echo "# "
fi

if test "${ARGS}"
then
	echo "# Args: ${ARGS}"
	echo "# "
fi

exit 1
echo "# "
echo "# Output will be written to: ${STDOUT}"
echo "# Stderr will be written to: ${STDERR}"
echo "# "


./2-analyze-sentiment  --num ${NUM} ${ARGS} >> ${STDOUT} 2>> ${STDERR}


