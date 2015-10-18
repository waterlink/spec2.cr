module Spec2
  module Matchers
    class Close < Matcher
      getter actual, expected, delta
      getter! actual_delta
      def initialize(@expected, @delta)
      end

      def match(@actual)
        @actual_delta = (actual - expected).abs
        actual_delta < delta
      end

      def failure_message
        "Expected to be close:
        Expected:  #{expected.inspect}
        Actual:    #{actual.inspect}
        Max-delta: #{delta.inspect}
        Delta:     #{actual_delta.inspect}"
      end

      def failure_message_when_negated
        "Expected to be not close:
        Expected:  #{expected.inspect}
        Actual:    #{actual.inspect}
        Min-delta: #{delta.inspect}
        Delta:     #{actual_delta.inspect}"
      end

      def description
        "(be close to #{expected.inspect} (delta=#{delta.inspect}))"
      end
    end

    def be_close(expected, delta)
      Close.new(expected, delta)
    end
  end
end
