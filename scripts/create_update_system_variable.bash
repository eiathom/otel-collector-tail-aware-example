#!/bin/bash
set -o pipefail

PARAMETER_KEY_NAME=${PARAMETER_KEY_NAME}
PARAMETER_VALUE=${PARAMETER_VALUE}

# check variable is set
if [ -z "${PARAMETER_KEY_NAME}" ]; then
  echo "ERROR: 'PARAMETER_KEY_NAME' is unset, exiting"
  exit 1
fi

# check vaiable is set
if [ -z "${PARAMETER_VALUE}" ]; then
  echo "ERROR: 'PARAMETER_VALUE' is unset, exiting"
  exit 1
fi

# check that the AWS CLI is installed
aws_command=$(which aws)
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to determine AWS CLI command location, exiting; is it installed locally?"
  exit 1
fi

# put the parameter
${aws_command} ssm put-parameter --name "${PARAMETER_KEY_NAME}" --value "${PARAMETER_VALUE}" --type String --overwrite 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to create/update variable '${PARAMETER_KEY_NAME}', exiting"
  exit 1
fi

# check the parameter exists
${aws_command} ssm get-parameter --name "${PARAMETER_KEY_NAME}" 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Parameter '${PARAMETER_KEY_NAME}' does not exist, exiting"
  exit 1
else
  echo "INFO: System variable '${PARAMETER_KEY_NAME}' created/updated"
fi