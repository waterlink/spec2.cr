module Spec2
  module Matchers
    class Eq(T)
      include Matcher
      getter expected
      getter actual_representation : String?

      def initialize(@expected : T)
      end

      def match(actual)
        @actual_representation = actual.inspect
        expected == actual
      end

      def failure_message
        "Expected to be equal:\n\t\tExpected:\t #{expected.inspect}\n\t\tActual:\t\t #{actual_representation}\n"
      end

      def failure_message_when_negated
        "Expected not to be equal:\n\t\tExpected;\t #{expected.inspect}\n\t\tActual:\t\t #{actual_representation}\n"
      end

      def description
        "(== #{expected.inspect})"
      end
    end

    Spec2.register_matcher(eq) { |expected| Eq.new(expected) }
  end
end
