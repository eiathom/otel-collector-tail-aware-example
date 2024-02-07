#!/bin/bash
set -o pipefail

BUCKET_NAME=${BUCKET_NAME}
FILE_NAME=${FILE_NAME}

# check variable is set
if [ -z "${BUCKET_NAME}" ]; then
  echo "ERROR: 'BUCKET_NAME' is unset, exiting"
  exit 1
fi

# check vaiable is set
if [ -z "${FILE_NAME}" ]; then
  echo "ERROR: 'FILE_NAME' is unset, exiting"
  exit 1
fi

# find the full pacth of the repo
full_path_of_directory=$(git rev-parse --show-toplevel)

# build the full file path of the file
file_full_path=$(find ${full_path_of_directory} -type f -name "${FILE_NAME}")

# check of the file exists (locally)
if [ ! -n "${file_full_path}" ]; then
  echo "ERROR: '${FILE_NAME}' file is not found, exiting"
  exit 1
fi

# check that the AWS CLI is installed
aws_command=$(which aws)
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to determine AWS CLI command location, exiting; is it installed locally?"
  exit 1
fi

# check of the bucket exists
if ${aws_command} s3api head-bucket --bucket "${BUCKET_NAME}" > /dev/null 2>&1; then
  echo "INFO: Bucket '${BUCKET_NAME}' exists, proceeding with upload attempt..."
else
  echo "ERROR: Bucket '${BUCKET_NAME}' does not exist or you do not have permission to access it, exiting"
  exit 1
fi

# upload the local file to remote
aws s3 cp "${file_full_path}" "s3://${BUCKET_NAME}/${FILE_NAME}" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "INFO: '${FILE_NAME}' uploaded to ${BUCKET_NAME} bucket successfully"
else
  echo "ERROR: '${FILE_NAME}' upload to ${BUCKET_NAME} bucket failed"
  exit 1
fi
