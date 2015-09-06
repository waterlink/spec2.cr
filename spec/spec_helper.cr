require "../src/spec2"

TestReporter = Spec2::Reporters::SingletonTest.new

def with_runner
  real_runner = Spec2.runner
  test_runner = Spec2::Runner.new
  test_runner.configure_reporter(TestReporter)
  TestReporter.reset
  Spec2.configure_runner(test_runner)

  yield

  Spec2.configure_runner(real_runner)
  test_runner
end
