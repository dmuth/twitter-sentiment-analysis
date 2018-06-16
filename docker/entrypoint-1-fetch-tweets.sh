#!/bin/bash
#
# Script to run our tweet fetching script.
#


OUTPUT=logs/1-tweet-fetch.log
STDERR=logs/1-tweet-fetch.stderr
STRING=${STRING:=anthrocon}
NUM=${NUM:=5}
ARGS=""

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
echo "# Available env vars: NUM, STRING, LOOP_SECONDS, RESULT_TYPE"
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
echo "# Output will be written to: ${OUTPUT}"
echo "# Stderr will be written to: ${STDERR}"
echo "# "


./1-fetch-tweets --search ${STRING} --num ${NUM} ${ARGS} >> ${OUTPUT} 2>> ${STDERR}


