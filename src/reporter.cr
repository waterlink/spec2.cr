module Spec2
  module Reporter
    Factory.abstract
    abstract def configure_output(output)
    abstract def context_started(context)
    abstract def context_finished(context)
    abstract def example_started(example)
    abstract def example_succeeded(example)
    abstract def example_failed(example, exception)
    abstract def example_errored(example, exception)
    abstract def report
  end
end
