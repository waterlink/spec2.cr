module Spec2
  macro enable_should_on_object
    class Object
      def should(matcher)
        ::Spec2::Context.expect(self).to matcher
      end

      def should_not(matcher)
        ::Spec2::Context.expect(self).not_to matcher
      end
    end
  end
end
