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

  class Hook
    getter block

    def initialize(&@block : (Example) ->)
    end

    def call(example)
      block.call(example)
    end
  end

  class Context
    getter what, description, examples, before_hooks, after_hooks, lets

    def initialize(@what)
      @description = @what.to_s
      @examples = [] of HighExample
      @lets = {} of String => Let
      @before_hooks = [] of Hook
      @after_hooks = [] of Hook
    end

    def examples
      return _examples.shuffle if Spec2.random_order?
      _examples
    end

    def _examples
      @examples
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

  module Macros
    macro describe(what, &block)
      context = ::Spec2::Context.new({{what}})
      Spec2._contexts << context

      macro it(description, &block)
        example = ::Spec2::Example.new(context, context.what, \{{description}})
        context._examples << ::Spec2::HighExample.new(example) do
          example.call \{{block}}
        end
      end

      macro it(&block)
        it(\{{block.body.stringify}}) \{{block}}
      end

      macro before(&block)
        hook = ::Spec2::Hook.new do |example|
          example.call \{{block}}
        end
        context.before_hooks << hook
      end

      macro after(&block)
        hook = ::Spec2::Hook.new do |example|
          example.call \{{block}}
        end
        context.after_hooks << hook
      end

      macro let(name, &block)
        a_let = ::Spec2::Let(\{{name.type.id}}).new(\{{name.stringify}}) \{{block}}
        context.lets[\{{name.var.stringify}}] = a_let
        macro \{{name.var.id}}
          context.lets[\{{name.var.stringify}}].not_nil!.call as \{{name.type.id}}
        end
      end

      macro let!(name, &block)
        let(\{{name}}) \{{block}}
        before { \{{name.var.id}} }
      end

      macro subject(name, &block)
        \{% if name.is_a?(DeclareVar) %}
           let(\{{name}}) \{{block}}
        \{% else %}
           let(subject :: \{{name.id}}) \{{block}}
        \{% {{:end.id}} %}
      end

      macro is_expected
        expect(subject)
      end

      {{block.body}}
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
        context.before_hooks.each do |hook|
          hook.call(high_example.example)
        end

        begin
          count += 1
          high_example.call
          context.after_hooks.each do |hook|
            hook.call(high_example.example)
          end
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
