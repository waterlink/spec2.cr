require "colorize"

require "./matcher"
require "./matchers/*"
require "./exceptions"
require "./expectation"

require "./next"

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
require "./elapsed_time"

module Spec2
  extend self

  @@high_runner = HighRunner.new(Context.instance)
  @@started_at = Time.now

  def high_runner
    @@high_runner
  end

  def started_at
    @@started_at
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

  macro describe(what, focused = false, file = __FILE__, line = __LINE__, &block)
    ::Spec2::DSL.describe({{what}}, {{focused}}, {{file}}, {{line}}) {{block}}
  end

  macro fdescribe(what, file = __FILE__, line = __LINE__, &block)
    ::Spec2.describe({{what}}, true, {{file}}, {{line}}) {{block}}
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
