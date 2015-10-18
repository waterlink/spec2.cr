module Spec2
  module Matchers
    class Satisfy(T)
      getter! failure_message, failure_message_when_negated
      def initialize(&@block : T -> {Bool, String, String})
      end

      def match(actual : T)
        ok, @failure_message, @failure_message_when_negated = @block.call(actual)
        ok
      end
    end
  end
end
