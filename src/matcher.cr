module Spec2
  abstract class Matcher
    abstract def match(actual)
    abstract def failure_message
    abstract def failure_message_when_negated
    abstract def description
  end

  macro register_matcher(name, &block)
    module ::Spec2::Matchers
      def {{name.id}}({{block.args.argify}})
        {{block.body}}
      end
    end
  end
end
