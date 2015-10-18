module Spec2
  module Matchers
    class Be < Matcher
      getter expected, actual
      def initialize(@expected)
      end

      def match(@actual)
        expected.same?(actual)
      end

      def failure_message
        "Expected to be the same:
        Expected: #{expected.inspect}
        Actual:   #{actual.inspect}"
      end

      def failure_message_when_negated
        "Expected to be different:
        Expected: #{expected.inspect}
        Actual:   #{actual.inspect}"
      end

      def description
        "(be #{expected.inspect})"
      end
    end
  end

  register_matcher(be) do |expected|
    Matchers::Be.new(expected)
  end
end
