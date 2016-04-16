module Spec2
  module Matchers
    class BeA(T)
      include Matcher
      getter actual_representation : String?

      def match(actual)
        @actual_representation = actual.inspect
        actual.is_a?(T)
      end

      def failure_message
        "Expected #{actual_representation} to be a #{T}"
      end

      def failure_message_when_negated
        "Expected #{actual_representation} not to be a #{T}"
      end

      def description
        "(a #{T})"
      end
    end

    macro be_a(t)
      BeA({{t}}).new
    end
  end
end
