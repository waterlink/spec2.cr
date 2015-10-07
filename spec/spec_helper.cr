require "../src/spec2"

TestReporter = Spec2::Reporters::SingletonTest.new

RUNNERS = {} of String => Spec2::Runner
FAKE_ROOTS = [] of Int32

macro with_runner(name, &block)
  {% FAKE_ROOTS << 0 %}

  {% fake_root_name = "TestRootContext__#{name.id}_#{FAKE_ROOTS.size}" %}

  class {{fake_root_name.id}} < Spec2::Context; end
  %root = {{fake_root_name.id}}.instance

  %real_runner = Spec2.runner
  %test_runner = Spec2::Runner.new(%root)
  %test_runner.configure_reporter(TestReporter)
  TestReporter.reset
  Spec2.configure_runner(%test_runner)

  {% ::Spec2::META["parent"] << fake_root_name.id %}
  {% ::Spec2::META["current"] << fake_root_name.id %}
  {{block.body}}

  Spec2.configure_runner(%real_runner)
  RUNNERS[{{name}}] = %test_runner
end
