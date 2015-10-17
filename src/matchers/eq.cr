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
        "Expected to be equal:\n\t\tExpected:\t #{expected.inspect}\n\t\tActual:\t\t #{actual.inspect}\n"
      end

      def failure_message_when_negated
        "Expected not to be equal:\n\t\tExpected;\t #{expected.inspect}\n\t\tActual:\t\t #{actual.inspect}\n"
      end
    end

    def eq(expected)
      Eq.new(expected)
    end
  end
end
