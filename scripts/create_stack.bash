#!/bin/bash
set -o pipefail

STACK_NAME=${STACK_NAME}
STACK_FILE_NAME=${STACK_FILE_NAME}

if [ -z "${STACK_NAME}" ]; then
  echo "ERROR: 'STACK_NAME' is unset, exiting"
  exit 1
fi

if [ -z "${STACK_FILE_NAME}" ]; then
  echo "ERROR: 'STACK_FILE_NAME' is unset, exiting"
  exit 1
fi

full_path_of_directory=$(git rev-parse --show-toplevel)
stack_file_full_path=$(find ${full_path_of_directory} -type f -name "${STACK_FILE_NAME}")
if [ -n "${stack_file_full_path}" ]; then
    echo "Full path of '${STACK_FILE_NAME}' is '${stack_file_full_path}'"
else
    echo "ERROR: '${STACK_FILE_NAME}' file is not found, exiting"
    exit 1
fi

aws_command=$(which aws)
if [ $? -ne 0 ]; then
  echo "Unable to determine AWS CLI command location; is it installed locally?"
  exit 1
fi

# check if stack exists
${aws_command} cloudformation describe-stacks --stack-name ${STACK_NAME} 2>&1
if [ $? -ne 0 ]; then
  echo "Stack '${STACK_NAME}' does not exist, creating from stack file '${STACK_FILE_NAME}'..."
  ${aws_command} cloudformation create-stack \
    --stack-name "${STACK_NAME}" \
    --template-body "file://${stack_file_full_path}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --on-failure DELETE

  echo "Waiting for stack to be created, please wait..."
  ${aws_command} cloudformation wait stack-create-complete --stack-name ${STACK_NAME}

  echo "Checking stack has been created successfully..."
  ${aws_command} cloudformation describe-stacks --stack-name ${STACK_NAME} 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR: 'Could not determine if ${STACK_NAME}' has been created; check console"
    exit 1
  else
    echo "Stack '${STACK_NAME}' created"
  fi
else
  echo "Nothing to do, '${STACK_NAME}' already exists"
  exit 0
fi
