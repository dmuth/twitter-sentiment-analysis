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
ln -sf ../../Dockerfile-0-get-twitter-credentials .
ln -sf ../../Dockerfile-1-fetch-tweets .
ln -sf ../../Dockerfile-2-analyze-tweets .
ln -sf ../../Dockerfile-3-export-tweets .
ln -sf ../../Dockerfile-4-backup .

echo "# "
echo "# Smylinking logs directory..."
echo "# "
ln -sf ../../logs/${NAME} logs

echo "# "
echo "# Writing docker-compose.yml..."
echo "# "
cat ../../docker-compose.yml.agent \
	| sed -e "s/%%SEARCH%%/${SEARCH}/" -e "s#%%S3%%#${S3}#" \
	> docker-compose.yml

echo "# Done!"

