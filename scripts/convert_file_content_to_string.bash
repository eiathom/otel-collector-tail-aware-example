#!/bin/bash
set -o pipefail

FILE_NAME=${FILE_NAME}

# check vaiable is set
if [ -z "${FILE_NAME}" ]; then
  echo "ERROR: 'FILE_NAME' is unset, exiting"
  exit 1
fi

# find the full path of the repo
full_path_of_directory=$(git rev-parse --show-toplevel)

# build the full file path of the file
file_full_path=$(find ${full_path_of_directory} -type f -name "${FILE_NAME}")

# check of the file exists (locally)
if [ ! -n "${file_full_path}" ]; then
  echo "ERROR: '${FILE_NAME}' file is not found, exiting"
  exit 1
fi

# convert content to string
echo "\"$(cat ${file_full_path})\""
