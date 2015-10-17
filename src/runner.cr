module Spec2
  class Runner
    getter reporter, root, current_context
    def initialize(@root)
      @current_context = root
    end

    def contexts
      [root]
    end

    def configure_reporter(@reporter)
    end

    def run_context(reporter, context)
      old_context = current_context
      @current_context = context
      reporter.context_started(context)

      context.examples.each do |example|
        begin
          reporter.example_started(example)
          context.run_before_hooks(context)
          example.call(context)
          context.run_after_hooks(context)
          context.clear_lets
          reporter.example_succeeded(example)
        rescue e : ExpectationNotMet
          reporter.example_failed(example, e.with_example(example))
        rescue e
          reporter.example_errored(
            example,
            ExpectationNotMet.new(e.message, e).with_example(example),
          )
        end
      end

      context.contexts.each do |nested_context|
        run_context(reporter, nested_context)
      end
    ensure
      @current_context = old_context
    end

    def run
      reporter_class = self.reporter
      unless reporter_class
        raise ReporterIsNotConfigured.new(
          "Please configure reporter with Spec2.configure_reporter(reporter)",
        )
      end

      reporter = reporter_class.new
      run_context(reporter, root)
      reporter.report
    end
  end
end
