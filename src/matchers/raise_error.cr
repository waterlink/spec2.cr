module Spec2
  module Matchers
    macro raise_error(klass=Exception, message=nil)
      ::Spec2::Matchers::Satisfy(->).new do |block|
        actual = "no error"
        ok = false
        add_failure = ""
        add_negated = ""
        message = {{message}}

        begin
          block.call

        rescue e : {{klass}}
          actual = "#{e.class}: #{e}"

          if message
            unless message.is_a?(::Spec2::Matcher)
              message = ::Spec2::Matchers::Eq.new(message)
            end
            ok = message.match(e.message)
            add_failure = message.failure_message
            add_negated = message.failure_message_when_negated
          else
            ok = true
          end

        rescue e
          actual = "#{e.class}: #{e}"
          ok = false
        end

        message_description = ""
        message_description = message.description if message.is_a?(::Spec2::Matcher)

        failure = "Expected block to fail with #{{{klass}}} #{message_description}
        But got: #{actual}
        #{add_failure}"

        negated = "Expected block not to fail with #{{{klass}}} #{message_description}
        But got: #{actual}
        #{add_negated}"

        {ok, failure, negated}
      end
    end
  end
end
