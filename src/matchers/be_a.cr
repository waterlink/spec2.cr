module Spec2
  module Matchers
    class BeA(T)
      include Matcher
      getter actual

      def match(@actual)
        actual.is_a?(T)
      end

      def failure_message
        "Expected #{actual.inspect} to be a #{T}"
      end

      def failure_message_when_negated
        "Expected #{actual.inspect} not to be a #{T}"
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
