module Spec2
  module Reporters
    class Default < Reporter
      def initialize
        @count = 0
        @errors = [] of ExpectationNotMet
      end

      def example_started(example)
        @count += 1
      end

      def example_succeeded(example)
        print "."
      end

      def example_failed(example, exception)
        @errors << exception
        print "F"
      end

      def example_errored(example, exception)
        @errors << exception
        print "E"
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
        puts "Examples: #{@count}, failures: #{@errors.count}"
      end
    end
  end
end
