#!/bin/bash
#
# Back up our database to S3.
#

# Errors are fatal
set -e

LOOP_SECONDS=${LOOP_SECONDS:=900}
NUM_TO_KEEP=${NUM_TO_KEEP:=40}

STDOUT=../logs/4-tweet-backups.log
STDERR=../logs/4-tweet-backups.stderr

#
# If we're in debug mode, write to stdout.  This is useful for development.
#
if test "$DEBUG"
then
	echo "##### DEBUG MODE ENABLED: Writing to stdout and stderr!"
	STDOUT=/dev/stdout
	STDERR=/dev/stderr
fi


#
# Check for and copy in our AWS credentials from the host container.
#
AWS_CREDS=/mnt/docker/aws-credentials.txt
if test ! -f $AWS_CREDS
then
	echo "! "
	echo "! AWS Credentials not found in $AWS_CREDS!  Stopping."
	echo "! "
	exit 1
fi

cp $AWS_CREDS $HOME/.aws/credentials

#
# Change to the directoy where this script is.
# We have this here in part so that we can run the script while in the container
# for development.
#
pwd
pushd $(dirname $0) > /dev/null
pwd

if test ! "$S3"
then
	echo "! "
	echo "! Environment variable \"S3\" needs to be set with the S3 bucket to backup to!"
	echo "! "
	exit 1
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
echo "# Available env vars: S3 LOOP_SECONDS DEBUG"
echo "# "
echo "# Backing up to S3 location: ${S3}"
echo "# Looping this many seconds: ${LOOP_SECONDS}"
echo "# "
echo "# Output will be written to: ${STDOUT}"
echo "# Stderr will be written to: ${STDERR}"
echo "# "


while true
do

	FILE=$(date +%Y%m%d-%H%M%S)
	TARGET="${S3}tweets-${FILE}.db"

	TMP=$(mktemp /tmp/backup-XXXXXXX)

	echo "# Making a copy of the database..." >> $STDOUT 2>>$STDERR
	cp /mnt/tweets.db $TMP >> $STDOUT 2>>$STDERR

	echo "# Now backing up database to '$TARGET' on S3..." >> $STDOUT 2>>$STDERR
	aws s3 cp $TMP $TARGET >> $STDOUT 2>>$STDERR

	#
	# Remove our temp file
	#
	rm -f $TMP >> $STDOUT 2>>$STDERR

	#
	# Delete all but the most recent backups
	# (Hopefully there is versioning turned on in S3 just in case an older backup needs to be retrieved)
	#
	COUNT_DELETED=0
	LINES_TO_KEEP=$(( $NUM_TO_KEEP + 1 ))

	for FILE in $(aws s3 ls $S3 | sort -r | sed -n $LINES_TO_KEEP,\$p | awk '{ print $4 }' )
	do
		DELETE="${S3}${FILE}"
		aws s3 rm ${DELETE} >> $STDOUT 2>> $STDERR
		COUNT_DELETED=$(( $COUNT_DELETED + 1 ))

	done

	#
	# Put this output in a date format that Splunk will recognize
	#
	echo "$(date "+%Y-%m-%d %H:%M:%S"),$(date +%s%N | cut -b14-16) ok=1 num_to_keep=${NUM_TO_KEEP} old_backups_deleted=${COUNT_DELETED}" >> $STDOUT 2>>$STDERR

	echo "Sleeping for ${LOOP_SECONDS} seconds..." >> $STDOUT >> $STDERR
	sleep ${LOOP_SECONDS}

done


