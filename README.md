# otel-collector-tail-aware-example

Example AWS infrastructure for deploying the load balancing exporter Collector
and tail sampling processor Collector.

Learn about sampling, and the different sampling options available in
OpenTelemetry, see: https://opentelemetry.io/docs/concepts/sampling/

For this example we are focusing attention on tail (a.k.a tail-aware) sampling.

Head sampling should be transparently applied 'higher' up the signal networking
chain: close to the application / instrumentation.

## Developing

```bash
# install pyenv
curl https://pyenv.run | bash

# in this repository
# set the local python version in use
pyenv local $(head -1 .python-version)

# create a virtual environment
python -m venv venv

# activate the environment
source venv/bin/activate

# upgrade pip
python -m pip install --upgrade pip

# install dependencies
python -m pip install -r requirements/development.txt

# install cfn-lint
python -m pip install cfn-lint

# install checkov
python -m pip install checkov

# install aws cli
python -m pip install awscli

# configure aws cli
# (aws account access id and secret access id required)
aws configure

# user aws permission polices required
* EC2
* ECS
* CloudFormation
* CloudMap
* S3
* SSM
* IAM (Read-Only)

# run linting checks on the template
cfn-lint --template ./stack/cloudformation/main.yaml --region eu-west-1

# run security and compliance checks on the template
checkov --config-file .checkov.yaml -d ./stack/cloudformation

# create the bucket for the stacks
STACK_NAME=StackBucket STACK_FILE_NAME=stackbucket.yaml ./scripts/create_stack.bash

# publish telemetry backend API key as secure parameter
PARAMETER_KEY_NAME=/otel/collector/configuration/telemetry-backend-api-key \
    PARAMETER_VALUE="${TELEMETRY_API_KEY}" \
    SECURE_STRING=1 \
    ./scripts/create_update_system_variable.bash

# publish Collector configuration as parameters
PARAMETER_KEY_NAME=/otel/collector/configuration/loadbalancing-collector-conf-map-type \
    PARAMETER_VALUE="env:COLLECTOR_CONFIGURATION" \
    ./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/loadbalancing-collector-configuration \
    PARAMETER_VALUE="$(FILE_NAME=loadbalancing-collector-configuration.yaml ./scripts/convert_file_content_to_string.bash)" \
    ./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/tailaware-collector-conf-map-type \
    PARAMETER_VALUE="env:COLLECTOR_CONFIGURATION" \
    ./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/tailaware-collector-configuration \
    PARAMETER_VALUE="$(FILE_NAME=tailaware-collector-configuration.yaml ./scripts/convert_file_content_to_string.bash)" \
    ./scripts/create_update_system_variable.bash

# create a parameter-overrides string
PARAMETER_OVERRIDES_STRING="$(STACK_BUCKET_NAME=stack-bucket \
    ./scripts/generate_parameter_overrides_string.bash \
        main_parameters.yaml \
        dev)"

STACK_BUCKET_NAME=stack-bucket \
STACK_NAME=Main \
STACK_FILE_NAME=main.yaml \
PARAMETER_OVERRIDES_STRING="${PARAMETER_OVERRIDES_STRING}" \
./scripts/create_stack.bash

# install cloudformation to terraform transformer
# https://github.com/DontShaveTheYak/cf2tf
python -m pip install cf2tf

# convert cf to tf
cf2tf ./stack/cloudformation/main.yaml -o ./stack/terraform/main

# close the environment when done
deactivate

```
