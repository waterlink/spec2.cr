module Spec2
  module Matchers
    class Match(T)
      include Matcher

      getter expected
      getter actual_representation : String?

      def initialize(@expected : T)
      end

      def match(actual)
        @actual_representation = actual.inspect
        !!(actual =~ expected)
      end

      def failure_message
        "Expected to match:
        Expected: #{expected.inspect}
        Actual:   #{actual_representation}"
      end

      def failure_message_when_negated
        "Expected not to match:
        Expected: #{expected.inspect}
        Actual:   #{actual_representation}"
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
