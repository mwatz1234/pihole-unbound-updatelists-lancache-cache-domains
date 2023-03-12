#!/bin/bash

### Set variables, change as necessary ###
# Directory the git repository is synced to
GITSYNCDIR=~/cache-domains
# Your personalized config file from "Setting up our config.json file" step
DNSMASQCONFIG=/etc/cache-domains/config/config.json

# Create a new, random temp directory and make sure it was created, else exit
TEMPDIR=$(mktemp -d)

  if [ ! -e $TEMPDIR ]; then
      >&2 echo "Failed to create temp directory"
      exit 1
  fi

# Switch to the git directory and pull any new data
cd $GITSYNCDIR && \
 git fetch
  HEADHASH=$(git rev-parse HEAD)
  UPSTREAMHASH=$(git rev-parse master@{upstream})
  if [ "$HEADHASH" != "$UPSTREAMHASH" ]; then
      echo "Upstream repo has changed!" && git pull
     else
      echo "No changes to upstream repo!" && exit
  fi

# Copy the .txt files and .json file to the temp directory
cp `find $GITSYNCDIR -name "*.txt" -o -name cache_domains.json` $TEMPDIR

# Copy the create-dnsmasq.sh script to our temp directory
mkdir $TEMPDIR/scripts/ && \
  cp $GITSYNCDIR/scripts/create-dnsmasq.sh $TEMPDIR/scripts/ && \
  chmod +x $TEMPDIR/scripts/create-dnsmasq.sh

# Copy the config over
cp $DNSMASQCONFIG $TEMPDIR/scripts/

# Generate the dnsmasq files with the script
cd $TEMPDIR/scripts/ && \
  bash ./create-dnsmasq.sh > /dev/null 2>&1

# Copy the dnsmasq files
cp -r $TEMPDIR/scripts/output/dnsmasq/*.conf /etc/dnsmasq.d/

# Restart pihole-FTL
sudo service pihole-FTL restart

# Delete the temp directory to clean up files
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TEMPDIR"' EXIT
