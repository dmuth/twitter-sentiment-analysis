#!/bin/bash
#
# Copy the files from an agent's bin/ and lib/ directories to the parent.
#
# This is so that software development can be done in an agent 
# (which isn't revision controlled) and then copied to the root directory (which is).
#
# I'm not a huge fan of doing it this way, and am always
# looking for something better. :-)
#

# Errors are fatal
set -e

#
# Change to the directory where this script is located.
#
pushd $(dirname $0) >/dev/null
cd ..

TARGET="../.."

echo "# "
echo "# Copying bin/* to ${TARGET}/bin..."
echo "# "
cp -r bin/ ${TARGET}/bin

echo "# "
echo "# Copying lib/* to ${TARGET}/lib..."
echo "# "
cp -r lib/ ${TARGET}/lib

echo "# Done!"

