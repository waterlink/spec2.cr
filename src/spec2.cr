require "colorize"

require "./factory"

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

  @@started_at : Time?

  def high_runner
    @@high_runner
  end

  def record_started_at
    @@started_at = Time.now
  end

  def started_at
    @@started_at.not_nil!
  end

  def configure_high_runner(@@high_runner)
  end

  def random_order
    configure_order(Orders::Random)
  end

  delegate configure_reporter, to: high_runner
  delegate configure_runner, to: high_runner
  delegate configure_order, to: high_runner
  delegate configure_output, to: high_runner
  delegate current_context, to: high_runner
  delegate exit_code, to: high_runner
  delegate run, to: high_runner

  macro describe(what, file = __FILE__, line = __LINE__, &block)
    ::Spec2::DSL.describe({{what}}, {{file}}, {{line}}) {{block}}
  end
end

Spec2.record_started_at

Spec2.configure_runner(Spec2::Runners::Default)
Spec2.configure_reporter(Spec2::Reporters::Default)
Spec2.configure_order(Spec2::Orders::Default)
Spec2.configure_output(Spec2::Outputs::Default)

at_exit do
  Spec2.run
  exit(Spec2.exit_code)
end
