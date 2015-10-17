require "colorize"

require "./matcher"
require "./matchers/*"
require "./exceptions"
require "./expectation"
require "./example"
require "./context"
require "./runner"
require "./high_runner"
require "./runners/*"
require "./reporter"
require "./reporters/*"
require "./order"
require "./orders/*"
require "./output"
require "./outputs/*"
require "./should"
require "./global_dsl"

module Spec2
  extend self

  META = {
    "current" => [::Spec2::Context] of Class,
    "parent" => [::Spec2::Context] of Class,
  }

  CONTEXT_COUNTER = [] of Int32

  @@high_runner = HighRunner.new(Context.instance)

  def high_runner
    @@high_runner
  end

  def configure_high_runner(@@high_runner)
  end

  def random_order
    configure_order(Orders::Random)
  end

  delegate configure_reporter, high_runner
  delegate configure_runner, high_runner
  delegate configure_order, high_runner
  delegate configure_output, high_runner
  delegate current_context, high_runner
  delegate exit_code, high_runner
  delegate run, high_runner

  macro describe(what, file = __FILE__, line = __LINE__, &block)
    {% CONTEXT_COUNTER << 0 %}
    {% label = what.id.stringify.gsub(/[^A-Za-z0-9_]/, "_").capitalize + "_#{CONTEXT_COUNTER.size}" %}

    {% parent = META["current"][-1] %}
    class Spec2__{{label.id}} < {{parent}}
      {% old_parent = META["parent"][-1] %}
      {% META["parent"] << parent %}
      {% META["current"] << "Spec2__#{label.id}".id %}

      def what
        {{what}}
      end

      def description
        ({{ parent }}.instance.description + " " + what.to_s).strip
      end

      def file
        {{file}}
      end

      def line
        {{line}}
      end

      macro __spec2__restore_meta__
        \{% ::Spec2::META["current"] << {{META["parent"][-1]}} %}
        \{% ::Spec2::META["parent"] << {{old_parent}} %}
      end

      LETS = [] of String
      BEFORE = [] of ->
      AFTER = [] of ->

      {{block.body}}
      __spec2__restore_meta__
    end

    {{parent}}.instance.contexts << Spec2__{{label.id}}.instance
    ::Spec2::ContextRegistry.register_parent(Spec2__{{label.id}}, {{parent}})
  end
end

Spec2.configure_runner(Spec2::Runners::Default)
Spec2.configure_reporter(Spec2::Reporters::Default)
Spec2.configure_order(Spec2::Orders::Default)
Spec2.configure_output(Spec2::Outputs::Default)

at_exit do
  Spec2.run
  exit(Spec2.exit_code)
end
