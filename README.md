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

# set the local python version in use
pyenv local $(head -1 .python-version)

# create a virtual environment
python -m venv venv 

# activate the environment
source venv/bin/activate

# install dependencies
pip install -r requirements/development.txt

# run checks on the template for proper syntax
cfn-lint --template template.yaml --region us-east-1 --ignore-checks W

# close the environment when done
deactivate

```
