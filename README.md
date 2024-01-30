# otel-collector-tail-aware-example

Example AWS infrastructure for deploying the load balancing exporter Collector
and tail sampling processor Collector.

Learn about sampling, and the different sampling options available in
OpenTelemetry, see: https://opentelemetry.io/docs/concepts/sampling/

For this example we are focusing attention on tail (a.k.a tail-aware) sampling.

Head sampling should be transparently applied 'higher' up the signal networking
chain: close to the application / instrumentation.
