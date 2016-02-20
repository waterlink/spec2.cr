module Spec2
  module Matchers
    class Be
      include Matcher
      getter expected, actual

      def initialize(@expected)
      end

      def match(@actual)
        expected.same?(actual)
      end

      def failure_message
        "Expected to be the same:
        Expected: #{expected.inspect}
        Actual:   #{actual.inspect}"
      end

      def failure_message_when_negated
        "Expected to be different:
        Expected: #{expected.inspect}
        Actual:   #{actual.inspect}"
      end

      def description
        "(be #{expected.inspect})"
      end
    end

    class BeRecorder(T)
      def initialize(@actual : T, @expectation); end

      macro method_missing(name, args, block)
        ok = !!(@actual.{{name.id}}({{args.argify}}) {{block}})

        {% if args.size == 0 %}
             failure = "Expected #{@actual.inspect} to be {{name.id}}"
             negated = "Expected #{@actual.inspect} not to be {{name.id}}"
        {% end %}

        {% if args.size == 1 %}
             failure = "Expected #{@actual.inspect} to be {{name.id}} #{{{args.first.id}}}"
             negated = "Expected #{@actual.inspect} not to be {{name.id}} #{{{args.first.id}}}"
        {% end %}

        {% if args.size > 1 %}
             failure = "Expected #{@actual.inspect} to be {{name.id}} #{ { {{args.argify}} } }"
             negated = "Expected #{@actual.inspect} not to be {{name.id}} #{ { {{args.argify}} } }"
        {% end %}

        @expectation.callback(ok, failure, negated)
      end
    end
  end

  register_matcher(be) do |expected|
    Matchers::Be.new(expected)
  end
end
