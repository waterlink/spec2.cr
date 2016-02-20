module Spec2
  module Matchers
    class BeTruthy
      include Matcher
      getter actual

      def match(@actual)
        !!actual
      end

      def failure_message
        "Expected #{actual.inspect} to be truthy"
      end

      def failure_message_when_negated
        "Expeccted #{actual.inspect} not to be truthy"
      end

      def description
        "(is truthy)"
      end
    end

    class BeFalsey
      include Matcher
      getter actual

      def match(@actual)
        !actual
      end

      def failure_message
        "Expected #{actual.inspect} to be falsey"
      end

      def failure_message_when_negated
        "Expeccted #{actual.inspect} not to be falsey"
      end

      def description
        "(is falsey)"
      end
    end

    def be_true
      eq(true)
    end

    def be_false
      eq(false)
    end

    def be_truthy
      BeTruthy.new
    end

    def be_falsey
      BeFalsey.new
    end

    def be_nil
      eq(nil)
    end
  end
end
