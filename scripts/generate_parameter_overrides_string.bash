#!/bin/bash

set -o pipefail

file_name="${1}"
environment_name="${2}"

# check variable is set
if [ -z "${file_name}" ]; then
  echo "ERROR: 'file_name' is unset, exiting"
  exit 1
fi

# check vaiable is set
if [ -z "${environment_name}" ]; then
  echo "ERROR: 'environment_name' is unset, exiting"
  exit 1
fi

# check that GIT is installed
git_command=$(which git)
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to determine 'git' command location, exiting; is it installed locally?"
  exit 1
fi

# check that find is installed
find_command=$(which find)
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to determine 'find' command location, exiting; is it installed locally?"
  exit 1
fi

# check that python is installed
python_command=$(which python)
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to determine 'python' command location, exiting; is it installed locally?"
  exit 1
fi

# find the full pacth of the repo
full_path_of_directory=$(${git_command} rev-parse --show-toplevel)

# build the full file path of the file
file_full_path=$(${find_command} ${full_path_of_directory} -type f -name "${file_name}")

# check the file exists (locally)
if [ ! -n "${file_full_path}" ]; then
  echo "ERROR: '${file_name}' file is not found, exiting"
  exit 1
fi

# get the full path to the python script
python_script_file_name=cf_parameter_loader.py
python_script_full_path=$(${find_command} ${full_path_of_directory} -type f -name "${python_script_file_name}")
# check the file exists (locally)
if [ ! -n "${python_script_full_path}" ]; then
  echo "ERROR: '${python_script_file_name}' file is not found, exiting"
  exit 1
fi

# run the command
${python_command} ${python_script_full_path} ${file_full_path} ${environment_name}
