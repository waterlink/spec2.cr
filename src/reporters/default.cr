module Spec2
  module Reporters
    class Default < Reporter
      def initialize
        @count = 0
        @errors = [] of ExpectationNotMet
      end

      def context_started(context)
      end

      def example_started(example)
        @count += 1
        print example.description + ".. "
      end

      def example_succeeded(example)
        puts "OK"
      end

      def example_failed(example, exception)
        @errors << exception
        puts "F"
      end

      def example_errored(example, exception)
        @errors << exception
        puts "E"
      end

      def report
        puts

        @errors.each do |e|
          example = e.example.not_nil!
          puts
          puts "In example: #{example.description}"
          puts "\tFailure: #{e}"
          puts e.backtrace.map { |line| "\t#{line}" }.join("\n")
        end

        puts
        puts "Examples: #{@count}, failures: #{@errors.size}"
      end
    end
  end
end
