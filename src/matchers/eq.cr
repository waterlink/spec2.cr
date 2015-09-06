module Spec2
  module Matchers
    class Eq
      getter expected
      getter actual

      def initialize(@expected)
      end

      def match(@actual)
        expected == actual
      end

      def failure_message
        "Expected #{actual.inspect} to be equal to #{expected.inspect}"
      end

      def failure_message_when_negated
        "Expected #{actual.inspect} to be not equal to #{expected.inspect}"
      end
    end

    def eq(expected)
      Eq.new(expected)
    end
  end
end
