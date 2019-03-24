#!/bin/bash
# 
# This script deletes an agent's directory.
#
#

# Errors are fatal
set -e

if test ! "$1"
then
	echo "! "
	echo "! Syntax: $0 agent-name"
	echo "! "
	exit 1
fi


NAME=$1

#
# Change to the directory where this script lives
#
pushd $(dirname $0) >/dev/null

#
# Sanitize the name
#
NAME=$(echo "$NAME" | sed -e s/"[^A-Za-z0-9_-]"/_/g)

#
# Make sure the directory exists first!
#
DIR="agents/${NAME}"
if test ! -d $DIR
then
	echo "! "
	echo "! Directory '${DIR}' not found! Skipping directory deletion..."
	echo "! "

else
	echo "# "
	echo "# Deleting agent '${NAME}'..."
	echo "# "

	rm -rfv ${DIR}

fi

cd agents
SPLUNK_DIR=../splunk-app/default
INPUTS_IN="${SPLUNK_DIR}/inputs.conf.in"
INPUTS_OUT="${SPLUNK_DIR}/inputs.conf"

echo "# "
echo "# Removing ${INPUTS_OUT}..."
echo "# "
rm -f $INPUTS_OUT

echo "# "
echo "# Rewriting ${INPUTS_OUT} for each agent..."
echo "# "
for AGENT in *
do
	echo "# - $AGENT"
	cat $INPUTS_IN | sed -e "s/%%NAME%%/${AGENT}/" >> $INPUTS_OUT
done

echo "# "
echo "# Done!"

