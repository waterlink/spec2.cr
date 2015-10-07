require "../src/spec2"

TestReporter = Spec2::Reporters::SingletonTest.new

RUNNERS = {} of String => Spec2::Runner

macro with_runner(name, &block)
  class TestRootContext__{{name.id}} < Spec2::Context; end
  %root = TestRootContext__{{name.id}}.instance

  {% real_parent = ::Spec2::META["parent"][-1] %}
  {% real_current = ::Spec2::META["current"][-1] %}
  {% ::Spec2::META["parent"] << "TestRootContext__#{name}".id %}
  {% ::Spec2::META["current"] << "TestRootContext__#{name.id}".id %}

  %real_runner = Spec2.runner
  %test_runner = Spec2::Runner.new(%root)
  %test_runner.configure_reporter(TestReporter)
  TestReporter.reset
  Spec2.configure_runner(%test_runner)

  {{block.body}}

  Spec2.configure_runner(%real_runner)
  RUNNERS[{{name}}] = %test_runner
end
