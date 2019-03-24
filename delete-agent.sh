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
	echo "! Directory '${DIR}' not found!"
	echo "! "
	exit 1
fi

echo "# "
echo "# Deleting agent '${NAME}'..."
echo "# "

rm -rfv ${DIR}

echo "# Done!"

