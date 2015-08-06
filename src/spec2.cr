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
    getter example

    def with_example(@example)
      self
    end
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
    getter example

    def initialize(@example, &@block)
    end

    def call
      block.call
    end
  end

  class Let(T)
    getter name, block

    def initialize(@name, &@block : -> :: T)
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
      @lets = {} of String => Let
    end

    def examples
      return _examples.shuffle if Spec2.random_order?
      _examples
    end

    def _examples
      @examples
    end

    def lets
      @lets
    end

    macro it(description, &block)
      example = ::Spec2::Example.new(itself, what, {{description}})
      _examples << ::Spec2::HighExample.new(example) do
        example.call {{block}}
      end
    end

    macro let(name, &block)
      a_let = ::Spec2::Let({{name.type.id}}).new({{name.stringify}}) {{block}}
      lets[{{name.var.stringify}}] = a_let
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

    macro method_missing(name, args, block)
      context.lets[{{name}}].call({{args.argify}}) {{block}}
    end
  end

  @@contexts = [] of Context
  @@random_order = false

  def self.contexts
    return _contexts.shuffle if random_order?
    _contexts
  end

  def self._contexts
    @@contexts
  end

  def self.describe(what)
    context = Context.new(what)
    _contexts << context
    with context yield
  end

  def self.random_order
    @@random_order = true
  end

  def self.random_order?
    @@random_order
  end

  def self.run
    errors = [] of ExpectationNotMet
    count = 0

    contexts.each do |context|
      context.examples.each do |high_example|
        begin
          count += 1
          high_example.call
          print "."
        rescue e : ExpectationNotMet
          print "F"
          errors << e.with_example(high_example.example)
        rescue e
          print "E"
          errors << ExpectationNotMet.new(e.message, e).with_example(high_example.example)
        end
      end
    end
    puts

    errors.each do |e|
      example = e.example.not_nil!
      puts
      puts "In example: #{example.description}"
      puts "Failure: #{e}"
      puts e.backtrace.join("\n")
    end

    puts
    puts "Examples: #{count}, failures: #{errors.count}"
  end
end

at_exit do
  Spec2.run
end
