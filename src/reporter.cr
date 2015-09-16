module Spec2
  abstract class Reporter
    abstract def context_started(context)
    abstract def example_started(example)
    abstract def example_succeeded(example)
    abstract def example_failed(example)
    abstract def example_errored(example)
    abstract def report
  end
end
