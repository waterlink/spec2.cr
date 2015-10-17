module Spec2
  class Runner
    getter reporter, root
    def initialize(@root)
    end

    def contexts
      [root]
    end

    def configure_reporter(@reporter)
    end

    def run_context(reporter, context)
      reporter.context_started(context)

      context.examples.each do |example|
        begin
          reporter.example_started(example)
          context.before_hooks.each(&.call)
          example.call
          context.after_hooks.each(&.call)
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
