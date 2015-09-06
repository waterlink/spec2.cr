module Spec2
  class HighExample
    getter block
    getter example

    def initialize(@example, &@block)
    end

    def call
      block.call
    end
  end

  class Example
    include Matchers

    getter context
    getter description
    getter block

    def initialize(@context, context_description, description)
      @description = [context_description, description].join(" ")
    end

    def call
      with self yield
      self
    end

    def expect(actual)
      Expectation.new(actual)
    end
  end
end
