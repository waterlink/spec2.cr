module Spec2
  module Reporters
    struct TestEvent
      property event, example, exception

      def initialize(@event : Symbol, @example : Example?, @exception : Exception?)
      end
    end

    class Test
      include Reporter
      extend Reporter::Factory

      def self.build
        new
      end

      getter received
      def initialize
        @received = [] of TestEvent
      end

      def configure_output(output)
      end

      def context_started(context)
      end

      def context_finished(context)
      end

      def example_started(example)
        received << TestEvent.new(:example_started, example, nil)
      end

      def example_succeeded(example)
        received << TestEvent.new(:example_succeeded, example, nil)
      end

      def example_failed(example, exception)
        received << TestEvent.new(:example_failed, example, exception)
      end

      def example_errored(example, exception)
        received << TestEvent.new(:example_errored, example, exception)
      end

      def report
        received << TestEvent.new(:report, nil, nil)
      end
    end

    class SingletonTest
      def initialize
        @reporter = new_reporter
      end

      def new
        @reporter
      end

      def new_reporter
        Test.new
      end

      def reset
        @reporter = new_reporter
      end
    end
  end
end
