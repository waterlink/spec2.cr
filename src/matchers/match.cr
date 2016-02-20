module Spec2
  module Matchers
    class Match
      include Matcher
      getter expected, actual

      def initialize(@expected); end

      def match(@actual)
        !!(actual =~ expected)
      end

      def failure_message
        "Expected to match:
        Expected: #{expected.inspect}
        Actual:   #{actual.inspect}"
      end

      def failure_message_when_negated
        "Expected not to match:
        Expected: #{expected.inspect}
        Actual:   #{actual.inspect}"
      end

      def description
        "(=~ #{expected.inspect})"
      end
    end
  end

  register_matcher(match) do |expected|
    Matchers::Match.new(expected)
  end
end
