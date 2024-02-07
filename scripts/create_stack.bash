#!/bin/bash
set -o pipefail

STACK_NAME=${STACK_NAME}
STACK_FILE_NAME=${STACK_FILE_NAME}
PARAMETER_OVERRIDES_STRING=${PARAMETER_OVERRIDES_STRING}

if [ -z "${STACK_NAME}" ]; then
  echo "ERROR: 'STACK_NAME' is unset, exiting"
  exit 1
fi

if [ -z "${STACK_FILE_NAME}" ]; then
  echo "ERROR: 'STACK_FILE_NAME' is unset, exiting"
  exit 1
fi

if [ -z "${PARAMETER_OVERRIDES_STRING}" ]; then
  echo "WARNING: 'PARAMETER_OVERRIDES_STRING' is unset, will not attempt to override parameters within the Stack"
fi

full_path_of_directory=$(git rev-parse --show-toplevel)
stack_file_full_path=$(find ${full_path_of_directory} -type f -name "${STACK_FILE_NAME}")
if [ ! -n "${stack_file_full_path}" ]; then
  echo "ERROR: '${STACK_FILE_NAME}' file is not found, exiting"
  exit 1
fi

aws_command=$(which aws)
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to determine AWS CLI command location; is it installed locally?"
  exit 1
fi

echo "INFO: Create/Update Stack '${STACK_NAME}' from stack file '${STACK_FILE_NAME}'..."
# schedule a build of the stack at the CloudFormation service
if [ -z "${PARAMETER_OVERRIDES_STRING}" ]; then
  ${aws_command} cloudformation deploy --stack-name "${STACK_NAME}" --template-file "${stack_file_full_path}" --capabilities CAPABILITY_IAM > /dev/null 2>&1
else
  ${aws_command} cloudformation deploy --stack-name "${STACK_NAME}" --template-file "${stack_file_full_path}" --capabilities CAPABILITY_IAM --parameter-overrides "${PARAMETER_OVERRIDES_STRING}" > /dev/null 2>&1
fi
if [ $? -ne 0 ]; then
  echo "ERROR: Stack '${STACK_NAME}' could not be created, check AWS console"
  exit 1
fi

# check for the existence of the Stack
echo "INFO: Checking stack has been created successfully..."
${aws_command} cloudformation describe-stacks --stack-name ${STACK_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: 'Could not determine if ${STACK_NAME}' has been created; check AWS console"
  exit 1
else
  echo "INFO: Stack '${STACK_NAME}' created"
fi
