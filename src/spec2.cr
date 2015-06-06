require "./spec2/*"

module Spec2
  module Matchers
    class Eq
      getter expected
      getter actual

      def initialize(@expected)
      end

      def match(@actual)
        expected == actual
      end

      def failure_message
        "Expected #{actual.inspect} to be equal to #{expected.inspect}"
      end

      def failure_message_when_negated
        "Expected #{actual.inspect} to be not equal to #{expected.inspect}"
      end
    end

    def eq(expected)
      Eq.new(expected)
    end
  end

  class ExpectationNotMet < Exception
  end

  class Expectation
    getter actual
    getter matcher

    def initialize(@actual)
    end

    def to(@matcher)
      return if matcher.match(actual)
      raise ExpectationNotMet.new(matcher.failure_message)
    end

    def not_to(@matcher)
      return unless matcher.match(actual)
      raise ExpectationNotMet.new(matcher.failure_message_when_negated)
    end

    alias_method to_not, not_to
  end

  class HighExample
    getter block

    def initialize(&@block)
    end

    def call
      block.call
    end
  end

  class Context
    getter what
    getter description
    getter examples

    def initialize(@what)
      @description = @what.to_s
      @examples = [] of HighExample
    end

    macro it(description, &block)
      examples << ::Spec2::HighExample.new do
        ::Spec2::Example
          .new({{description}})
          .call {{block}}
      end
    end
  end

  class Example
    include Matchers

    getter context
    getter description
    getter block

    def initialize(@description)
    end

    def call
      with self yield
    end

    def expect(actual)
      Expectation.new(actual)
    end
  end

  @@contexts = [] of Context

  def self.contexts
    @@contexts
  end

  def self.describe(what)
    context = Context.new(what)
    contexts << context
    with context yield
  end

  def self.run
    contexts.each do |context|
      context.examples.each do |high_example|
        high_example.call
      end
    end
  end
end
