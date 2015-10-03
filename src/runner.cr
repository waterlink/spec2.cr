module Spec2
  class Runner
    def initialize
      @contexts = [] of Context
      @random_order = false
      @reporter = nil
    end

    def contexts
      return _contexts.shuffle if random_order?
      _contexts
    end

    def _contexts
      @contexts
    end

    def random_order
      @random_order = true
    end

    def random_order?
      @random_order
    end

    def configure_reporter(reporter)
      @reporter = reporter
    end

    def reporter
      @reporter
    end

    def run_context(reporter, context)
      reporter.context_started(context)

      context.examples.each do |high_example|
        example = high_example.example
        context.before_hooks.each do |hook|
          hook.call(example, context)
        end

        begin
          reporter.example_started(example)
          high_example.call(context)
          context.after_hooks.each do |hook|
            hook.call(example, context)
          end
          reporter.example_succeeded(example)
        rescue e : ExpectationNotMet
          reporter.example_failed(example, e.with_example(example))
        rescue e
          reporter.example_errored(
            example,
            ExpectationNotMet.new(e.message, e).with_example(example),
          )
        ensure
          context.reset
        end
      end

      context.contexts.each do |nested_context|
        run_context(reporter, nested_context)
      end
    end

    def run
      reporter_class = self.reporter
      unless reporter_class
        raise ReporterIsNotConfigured.new(
          "Please configure reporter with Spec2.configure_reporter(reporter)",
        )
      end

      reporter = reporter_class.new

      contexts.each do |context|
        run_context(reporter, context)
      end

      reporter.report
    end
  end
end
