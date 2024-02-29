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

# ensure that when URL are in command that they are not treated as URL to target
aws configure set cli_follow_urlparam false

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
STACK_NAME=StackBucket \
STACK_FILE_NAME=stackbucket.yaml \
./scripts/create_stack.bash

# publish telemetry backend API key as secure parameter
PARAMETER_KEY_NAME=/otel/collector/configuration/telemetry-backend-api-key \
PARAMETER_VALUE="${TELEMETRY_API_KEY}" \
SECURE_STRING=1 \
./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/telemetry-backend-endpoint \
PARAMETER_VALUE="${TELEMETRY_BACKEND_ENDPOINT}" \
SECURE_STRING=1 \
./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/telemetry-backend-user \
PARAMETER_VALUE="${TELEMETRY_BACKEND_USER}" \
SECURE_STRING=1 \
./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/telemetry-backend-token \
PARAMETER_VALUE="${TELEMETRY_BACKEND_TOKEN}" \
SECURE_STRING=1 \
./scripts/create_update_system_variable.bash

# publish Collector configuration as parameters
PARAMETER_KEY_NAME=/otel/collector/configuration/loadbalancing-collector-conf-map-type \
PARAMETER_VALUE="env:COLLECTOR_CONFIGURATION" \
./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/loadbalancing-collector-configuration \
PARAMETER_VALUE="$(FILE_NAME=loadbalancing-collector-configuration.yaml \
    ./scripts/convert_file_content_to_string.bash)" \
./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/tailaware-collector-conf-map-type \
PARAMETER_VALUE="env:COLLECTOR_CONFIGURATION" \
./scripts/create_update_system_variable.bash

PARAMETER_KEY_NAME=/otel/collector/configuration/tailaware-collector-configuration \
PARAMETER_VALUE="$(FILE_NAME=tailaware-collector-configuration.yaml \
    ./scripts/convert_file_content_to_string.bash)" \
./scripts/create_update_system_variable.bash

# create a parameter-overrides string
STACK_BUCKET_NAME=stack-bucket \
PARAMETER_OVERRIDES_STRING="$(STACK_BUCKET_NAME=${STACK_BUCKET_NAME} \
    ./scripts/generate_parameter_overrides_string.bash \
        main_parameters.yaml \
        dev)"

STACK_BUCKET_NAME=stack-bucket \
STACK_NAME=Main \
STACK_FILE_NAME=main.yaml \
PARAMETER_OVERRIDES_STRING="${PARAMETER_OVERRIDES_STRING}" \
./scripts/create_stack.bash

# checking collector functionality
curl -X POST -H "Content-Type: application/json" -d @collector/payload/traces.json -i ALB_ADDRESS/v1/traces

# install cloudformation to terraform transformer
# https://github.com/DontShaveTheYak/cf2tf
python -m pip install cf2tf

# convert cf to tf
cf2tf ./stack/cloudformation/main.yaml -o ./stack/terraform/main

# close the environment when done
deactivate

```

## Querying / visualising stored telemetry data

OpenTelemetry (OTEL) is the complete solution for describing systems via data.
It is modular, extensible, adheres to industry standards, and powerful. The tooling
provided by OpenTelemetry - as well as the specification - help systems designers
deliver on the ideal of a system to be termed as 'observable'.

The choice of telemetry back-end is totally up to user preference. There are a
number of systems which store, provide a query engine, and visualise telemetry
data as an all-in-one - **managed** - solution (at various levels of user
maturity):

* [Grafana Cloud](https://grafana.com/) is the most complete telemetry
solution on the market totally geared towards OTEL, focused mature users
* [NewRelic](https://newrelic.com/) is a huge product, for novice users, which
is not geared towards OTEL
* [DataDog](https://www.datadoghq.com/) is a huge product, for novice users,
which is not geared towards OTEL

A fully **self-managed** solution can be obtained by leveraging:

* [Jaeger](https://www.jaegertracing.io/docs/1.54/deployment/#query-service--ui)
: span and metric storage query engine and telemetry visualisation
    * **NOTE:** [Grafana](https://grafana.com/grafana/) is also - in it's
    basic form - a visualisation tool
* [Cassandra](https://cassandra.apache.org/_/index.html): span storage
* [Prometheus](https://prometheus.io/docs/introduction/overview/): metric storage

Getting a Grafana Cloud account, creating an access policy (to ingest OTLP
spans, metrics and logs) to 'it', which can then be used as
an authentication mechanism to export OTLP from a deployed Collector
solution (like this one), is a fantastic decision anyone can make going forward.
