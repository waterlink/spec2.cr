module Spec2
  module Reporters
    class Default
      include Reporter
      extend Reporter::Factory

      def self.build
        new
      end

      getter! output
      def initialize
        @count = 0
        @pending = 0
        @errors = [] of ExpectationNotMet
      end

      def configure_output(@output : Output)
      end

      def context_started(context)
      end

      def context_finished(context)
      end

      def example_started(example)
        @count += 1
      end

      def example_succeeded(example)
        if example.pending?
          @pending += 1
          output.print :pending, "*"
        else
          output.print :success, "."
        end
      end

      def example_failed(example, exception)
        @errors << exception
        output.print :failure, "F"
      end

      def example_errored(example, exception)
        @errors << exception
        output.print :failure, puts "E"
      end

      def report
        output.puts

        @errors.each do |e|
          example = e.example.not_nil!
          output.puts
          output.puts :failure, "In example: #{example.description}"
          output.puts :failure, "\tFailure: #{e}"
          output.puts :failure, e.backtrace.map { |line| "\t#{line}" }.join("\n")
        end

        output.puts
        status = @errors.size > 0 ? :failure : :success
        output.puts "Finished in #{ElapsedTime.new.to_s}"
        output.puts status, "Examples: #{@count}, failures: #{@errors.size}, pending: #{@pending}"
      end
    end
  end
end
