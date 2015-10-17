require "./matchers/*"
require "./exceptions"
require "./expectation"
require "./example"
require "./context"
require "./runner"
require "./reporter"
require "./reporters/*"

module Spec2
  extend self

  META = {
    "current" => [::Spec2::Context] of Class,
    "parent" => [::Spec2::Context] of Class,
  }

  CONTEXT_COUNTER = [] of Int32

  @@runner = Runner.new(Context.instance)

  def runner
    @@runner
  end

  def configure_runner(@@runner)
  end

  delegate configure_reporter, runner

  def run
    runner.run
  end

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

      {{block.body}}
      __spec2__restore_meta__
    end

    {{parent}}.instance.contexts << Spec2__{{label.id}}.instance
    ::Spec2::ContextRegistry.register_parent(Spec2__{{label.id}}, {{parent}})
  end
end

Spec2.configure_reporter(Spec2::Reporters::Default)

at_exit do
  Spec2.run
end
