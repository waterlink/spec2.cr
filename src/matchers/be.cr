module Spec2
  module Matchers
    class Be(T)
      include Matcher
      getter expected
      getter actual_representation : String?

      def initialize(@expected : T)
      end

      def match(actual)
        @actual_representation = actual.inspect
        expected.same?(actual)
      end

      def failure_message
        "Expected to be the same:
        Expected: #{expected.inspect}
        Actual:   #{actual_representation}"
      end

      def failure_message_when_negated
        "Expected to be different:
        Expected: #{expected.inspect}
        Actual:   #{actual_representation}"
      end

      def description
        "(be #{expected.inspect})"
      end
    end

    class BeRecorder(T)
      def initialize(@actual : T, @expectation : ExpectationProtocol)
      end

      #macro method_missing(name, args, block)
      macro method_missing(call)
        ok = !!(@actual.{{call.name.id}}({{call.args.splat}}) {{call.block}})

        {% if call.args.size == 0 %}
             failure = "Expected #{@actual.inspect} to be {{call.name.id}}"
             negated = "Expected #{@actual.inspect} not to be {{call.name.id}}"
        {% end %}

        {% if call.args.size == 1 %}
             failure = "Expected #{@actual.inspect} to be {{call.name.id}} #{{{call.args.first.id}}}"
             negated = "Expected #{@actual.inspect} not to be {{call.name.id}} #{{{call.args.first.id}}}"
        {% end %}

        {% if call.args.size > 1 %}
             failure = "Expected #{@actual.inspect} to be {{call.name.id}} #{ { {{call.args.splat}} } }"
             negated = "Expected #{@actual.inspect} not to be {{call.name.id}} #{ { {{call.args.splat}} } }"
        {% end %}

        @expectation.callback(ok, failure, negated)
      end
    end
  end

  register_matcher(be) do |expected|
    Matchers::Be.new(expected)
  end
end
