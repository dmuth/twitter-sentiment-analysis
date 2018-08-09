
# Twitter Sentiment Analysis

This app makes use of Twitter's API and AWS Comprehend to get insights about your company,
city, event, or convention by way of analyzing tweet sentiment.  It further
allows drilldown by user, topic, and search string.


## Requirements

- Twitter credentials (these can be created on the fly when running the first script)
- AWS Credentials
- Working knowledge of <a href="http://splunk.com/">Splunk</a>.  There is some documentation <a href="http://docs.splunk.com/Documentation/Splunk/7.1.2/SearchTutorial/WelcometotheSearchTutorial">here</a>, but existing dashboards should be enough to get you started.
- Docker (optional)


## Screenshots

<a href="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/sentiment-breakdown-by-keyword.png"><img src="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/sentiment-breakdown-by-keyword.png" width="250" /></a> <a href="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/tag-cloud.png"><img src="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/tag-cloud.png" width="250" /></a> <a href="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/tweet-volume.png"><img src="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/tweet-volume.png" width="250" /></a>  <a href="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/sentiment-for-twitter-mentions.png"><img src="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/sentiment-for-twitter-mentions.png" width="250" /></a> <a href="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/search-tweets.png"><img src="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/search-tweets.png" width="250" /></a> <a href="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/service-status.png"><img src="https://raw.githubusercontent.com/dmuth/twitter-sentiment-analysis/master/img/service-status.png" width="250" /></a>


## Installation


### Setting up credentials

- Get your Twitter credentials:
   - `docker build -f ./Dockerfile-0-get-twitter-credentials -t 0-get-twitter-credentials . && docker run -v $(pwd):/mnt -it 0-get-twitter-credentials . && docker run -v $(pwd):/mnt -it 0-get-twitter-credentials`
   - Running this script will walk your through the steps, so it should be straightforward.
- Make sure you have <a href="https://aws.amazon.com/cli/">AWS CLI</a> installed and ran `aws configure` to enter your AWS credentials.
   - Access to a single S3 bucket and AWS Comprehend will be required
   - Note that if you create a policy for your IAM credentials (as you should!), the ARN in the Resource array must end in `/*`.  Exammple: `arn:aws:s3:::tweets/*`. There is a byg in the policy generator where this won't happen and your backups will fail.  Be careful


### Running the app

Now you can run the app via Docker:

- `cd docker/`
- `cp ~/.aws/credentials aws-credentials.txt`
- Copy `docker-compose.yml.example` to `docker-compose.yml` and edit the latter with things like your search string and other values
- `docker-compose up -d`

This will start up several Docker containers in the background running various Python
scripts and a copy of Splunk.  To access Splunk, go to https://localhost:8000/ and
log in with default credentials of `admin/password`.


## Architecture Overview

The following docker containers are used:

- `1-fetch-tweets`
   - Downloads tweets from Twitter with a search string in them.
- `2-analyze-tweets`
   - Sends tweets off to AWS to be analyzed
- `3-export-tweets`
   - Exports analyzed Tweets from the SQLite database to disk, where they can be analyzed
- `4-splunk`
   - Runs Splunk.
- `4-backup`
   - Does regular backups ofthe SQLIte database to AWS S3.


## Adding reports to Splunk

Feel free to edit/save new reports in Splunk, they will all show up in the `splunk-app/` directory.


## Data persistence

Splunk will save its index to `splunk-data/` between runs.


## Development

How to run the `backup` script in the foreground for development:
`docker-compose kill 4-backup && docker-compose rm -f 4-backup && docker-compose build 4-backup && docker-compose up 4-backup`



## Known Issues

Since the SQLite file `tweets.db` is shared between several containers/services, there may occasionally
be some contention, resulting in an error from SQLite that it can't lock `tweets.db`.  When this happens,
it triggers an exception in the Python code, causing it to exit, which causes the Docker container to
exit as well.  It will be restarted in accordance with Docker's restart policy, and the service will resume 
running.  This means that all Tweets will eventually make it into Splunk, but there may be a slight delay
if a lot of tweets are being processed.


## Credits

- Tag clouds in Splunk are created with the awesome Wordcloud app, available at <a href="https://splunkbase.splunk.com/app/3212">https://splunkbase.splunk.com/app/3212</a>


## TODO

- Don't copy AWS credentials into the image at build time, copy them in at run-time insead.
- Write up some "priming instructions" for large tweet volumes
- Allow multiple search terms (comma-delimited?)


## Contact

If there are any issues, feel
free to file an issue against this project, <a href="http://twitter.com/dmuth">hit me up on Twitter</a>
<a href="http://facebook.com/dmuth">or Facebook</a>, or drop me a line: **dmuth AT dmuth DOT org**.




