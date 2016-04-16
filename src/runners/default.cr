module Spec2
  module Runners
    class Default
      include Runner
      extend Runner::Factory

      def self.build
        new
      end

      @current_context : Context?
      getter current_context

      def failed?
        @failed
      end

      def run_context(reporter, order, context)
        old_context = current_context
        @current_context = context
        reporter.context_started(context)

        order.order(context.examples).each do |example|
          begin
            reporter.example_started(example)
            example.__spec2_clear_lets
            example.run
            example.__spec2_clear_lets
            reporter.example_succeeded(example)
          rescue e : ExpectationNotMet
            @failed = true
            reporter.example_failed(example, e.with_example(example))
          rescue e
            @failed = true
            reporter.example_errored(
              example,
              ExpectationNotMet.new(e.message, e).with_example(example),
            )
          end
        end

        order.order(context.contexts).each do |nested_context|
          run_context(reporter, order, nested_context)
        end
      ensure
        reporter.context_finished(context)
        @current_context = old_context
      end
    end
  end
end
