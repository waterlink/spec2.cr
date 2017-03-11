module Spec2
  module Reporters
    class Doc
      include Reporter
      extend Reporter::Factory

      def self.build
        new
      end

      getter! output, nesting
      def initialize
        @count = 0
        @pending = 0
        @errors = [] of ExpectationNotMet
        @nesting = 0
      end

      def configure_output(@output : Output)
      end

      def context_started(context)
        output.puts "#{indent}#{context.what}"
        @nesting = nesting + 1
      end

      def context_finished(context)
        @nesting = nesting - 1
      end

      def example_started(example)
        @count += 1
      end

      def example_succeeded(example)
        if example.pending?
          @pending += 1
          output.puts :pending, "#{indent}#{example.what}"
        else
          output.puts :success, "#{indent}#{example.what}"
        end
      end

      def example_failed(example, exception)
        @errors << exception
        output.puts :failure, "#{indent}#{example.what} (Failure)"
      end

      def example_errored(example, exception)
        @errors << exception
        output.puts :failure, "#{indent}#{example.what} (Error)"
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

      private def indent
        "    " * nesting
      end
    end
  end

  def self.doc
    configure_reporter(Reporters::Doc)
  end
end
