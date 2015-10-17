require "../src/spec2"

Spec2.random_order
Spec2.doc

TestReporter = Spec2::Reporters::SingletonTest.new

RUNNERS = {} of String => Spec2::HighRunner
FAKE_ROOTS = [] of Int32

module TestEvents
  def self.clear
    @@events = [] of Symbol
  end

  def self.events
    @@events ||= clear
  end
end

macro with_runner(name, &block)
  {% FAKE_ROOTS << 0 %}

  {% fake_root_name = "TestRootContext__#{name.id}_#{FAKE_ROOTS.size}" %}

  class {{fake_root_name.id}} < Spec2::Context; end
  %root = {{fake_root_name.id}}.instance

  %real_runner = Spec2.high_runner
  %test_runner = Spec2::HighRunner.new(%root)
  %test_runner.configure_reporter(TestReporter)
  %test_runner.configure_runner(::Spec2::Runners::Default)
  %test_runner.configure_order(::Spec2::Orders::Default)
  %test_runner.configure_output(::Spec2::Outputs::Default)
  TestReporter.reset
  Spec2.configure_high_runner(%test_runner)

  {% ::Spec2::META["parent"] << fake_root_name.id %}
  {% ::Spec2::META["current"] << fake_root_name.id %}
  {{block.body}}

  Spec2.configure_high_runner(%real_runner)
  RUNNERS[{{name}}] = %test_runner
end
