require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry/exporter/otlp'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'payments-processing'
  c.use_all
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: ENV['OTEL_EXPORTER_OTLP_TRACES_ENDPOINT']
      )
    )
  )
end

ServiceTraser = OpenTelemetry.tracer_provider.tracer('payments-processing-tracer')

#
# To implement a span within the traser, wrap the code you want to be
# part of the span like in the snippet below:
# PaymentsProcessingTracer.in_span('get-payment-by-id') do
#   <code>
# end
