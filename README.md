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

# run checks on the template for proper syntax
cfn-lint --template template.yaml --region us-east-1 --ignore-checks W

# create the stack
aws cloudformation create-stack --stack-name LoadBalancedTailAwareCollector \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --region eu-west-1 \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
  --on-failure DELETE

# check on stack progress
aws cloudformation describe-stack-events \
  --stack-name LoadBalancedTailAwareCollector \
  --output json

# delete the stack
aws cloudformation delete-stack \
  --stack-name LoadBalancedTailAwareCollector

# close the environment when done
deactivate

```
