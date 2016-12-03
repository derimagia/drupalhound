#!/bin/bash

# Usage:
# ./download.sh allmodules.txt 7 6 8 line1234
#
# Assumes allmodules.txt is a newline-separated list of projects you want to
# download.

drush_location=drush
line=1

# Versions to attempt to download, in order of preference.
versions=(7 8)

# Files are called "allsomething.txt"; strip the extension off and make it the
# download destination directory.
filename=$1
filename=${filename:-allmodules.txt}
dir=${filename%%.*}
shift

# Make sure drush works.
if [[ -n $($drush_location --version | grep Version) ]]; then
  echo "Yay, Drush works."
else
  echo "Hey, bozo. Drush is not in $drush_location. Fix that, or fix the drush_location variable."
  exit;
fi

# Allow for version numbers to be passed in.
versions=()
while [ $# -ne 0 ]
do
  # Get version number
  if  [[ "${1}" =~ ^[0-9]+$ ]] ; then
    versions+=(${1})
    shift
  # Get line number
  elif  [[ "${1}" == *line* ]] ; then
    line=(${1:4})
    shift
  fi
done

# Default versions to attempt to download, in order of preference.
if [ -z "${versions}" ]
then
  versions=(7 6 8)
fi

# If directory doesn't already exist, create it.
`mkdir -p $dir`

# Output what is about to happen.
echo -n "Total Number of lines: "
wc -l ${filename}
echo "Starting at line: ${line}"
echo "Will be trying to get the following version numbers: ${versions[@]}"
echo -e "Drush command is ${drush_location}\n"
sleep 1

# Read in the contents of the file, line by line. Each one is a project name.
counter=0
while read -r project
do
  ((counter++))
  if [[ "${counter}" -lt "${line}" ]]
  then
    continue
  fi

  echo -ne "\n${counter}\t$project"

  # Already have this one? Skip it!
  if [ -d "./$dir/$project" ]; then
    echo -ne "\tOK."
    continue
  else
    echo -ne "\tNEW."
  fi

  # Loop through each version.
  for version in ${versions[@]}
  do
    echo -ne "\n\t\tAttempting $version dev:"

    echo $drush_location dl --dev -y -q --destination=$dir --default-major=$version --package-handler=git_drupalorg $project

    # Attempt to download the project.
    # That funny 2>&1 business at the end will ensure that the output from
    # Drush can be inspected below.
    output=$( $drush_location dl --dev -y -q --destination=$dir --default-major=$version --package-handler=git_drupalorg $project 2>&1 )

    # If there is no development release for the project, let's grab the latest
    # stable version release. If more than one are presented, pick the first.
    if [[ "$output" == *warning* ]]
    then
        echo $project
        exit
      output=$( $drush_location dl -y -q --destination=$dir --choice=1 --default-major=$version --package-handler=git_drupalorg $project 2>&1 )
    fi

    # Unfortuantely, Drush commands return a success error code (0), even when
    # they don't work. :P Only way to see if this command failed is to check
    # the output of the script.
    # @todo Re-work this when http://drupal.org/node/1735230 is fixed.
    if [[ "$output" != *warning* ]];
    then
      # No problems? Move onto the next project!
      echo -n " Success!"
      break
    else
      echo -ne " Failed.\n\t\t$output"
      echo -ne "\t\t"
    fi
  done
done < ${filename}
echo ""
