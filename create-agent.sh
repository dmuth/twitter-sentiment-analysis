#!/bin/bash
#
# This script creates an agent directory and puts in things like 
# symlinks for scripts and Dockerfiles and rewrites docker-compose.yml
# to include search terms and S3 bucket backup info
#

# Errors are fatal
set -e

if test ! "$3"
then
	echo "! "
	echo "! Syntax: $0 agent-name \"searchterm1,searchterm2,etc.\" s3-backup-path"
	echo "! "
	exit 1
fi


NAME=$1
SEARCH=$2
S3=$3

#
# Change to the directory where this script lives
#
pushd $(dirname $0) >/dev/null

#
# Sanitize the name
#
NAME=$(echo "$NAME" | sed -e s/"[^A-Za-z0-9_-]"/_/g)

if [[ $S3 != s3://*/ ]]
then
	echo "! "
	echo "! S3 path must start with \"s3://\" and end with a slash!"
	echo "! "
	echo "! You entered: $S3"
	echo "! "
	exit 1
fi

echo "# "
echo "# Creating our directories..."
echo "# "
mkdir -p agents/${NAME}
mkdir -p logs/${NAME}

echo "# "
echo "# cding to agents/${NAME}..."
echo "# "
cd agents/${NAME}


echo "# "
echo "# Symlinking Dockerfiles..."
echo "# "
ln -sf ../../docker/Dockerfile-0-get-twitter-credentials .
ln -sf ../../docker/Dockerfile-1-fetch-tweets .
ln -sf ../../docker/Dockerfile-2-analyze-tweets .
ln -sf ../../docker/Dockerfile-3-export-tweets .
ln -sf ../../docker/Dockerfile-4-backup .

echo "# "
echo "# Symlinking bin directory..."
echo "# "
ln -sf ../../bin/ ./bin

echo "# "
echo "# Symlinking logs directory..."
echo "# "
ln -sf ../../logs/${NAME} logs

echo "# "
echo "# Symlinking in Python logging config..."
echo "# "
ln -sf ../../logging_config.ini .

echo "# "
echo "# Writing docker-compose.yml..."
echo "# "
cat ../../docker-compose.yml.agent \
	| sed -e "s/%%SEARCH%%/${SEARCH}/" -e "s#%%S3%%#${S3}#" -e "s/%%AGENT%%/${NAME}/" \
	> docker-compose.yml

#
# Change to the main agents directory and loop through each agent 
#
cd ..

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

echo "#"
echo "# Agent setup complete!"
echo "#"

cd $NAME
echo "# Checking for config.ini..."
if test ! -f "config.ini"
then
	echo "> "
	echo "> Looks like your config.ini file isn't set up--be sure to go"
	echo "> into this directory and run the following:"
	echo "> "
	echo "> docker build -f ./Dockerfile-0-get-twitter-credentials -t 0-get-twitter-credentials . && docker run -v \$(pwd):/mnt -it 0-get-twitter-credentials"
	echo "> "
fi

echo "# Checking for aws-credentials.txt..."
if test ! -f "aws-credentials.txt"
then
	echo "> "
	echo "> Looks like aws-credentials.txt isn't there, be sure to add it in"
	echo "> so that backups can be made."
	echo "> "
fi

echo "# Done!"


