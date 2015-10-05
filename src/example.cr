module Spec2
  class HighExample
    getter block
    getter example

    def initialize(@example, &@block : Context -> Void)
    end

    def call(context)
      block.call(context)
    end
  end

  class Example
    include Matchers

    getter current_context
    getter context
    getter description
    getter block

    def initialize(@context, context_description, description)
      @current_context = context
      @description = [context_description, description].join(" ")
    end

    def call(context)
      @current_context = context
      Spec2.execution_context = @current_context
      with self yield(context)
      self
    end

    def expect(actual)
      Expectation.new(actual)
    end
  end
end
