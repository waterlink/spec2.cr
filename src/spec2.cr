require "./matchers/*"
require "./exceptions"
require "./expectation"
require "./example"
require "./let"
require "./hook"
require "./context"
require "./macro"
require "./reporter"
require "./reporters/*"

module Spec2
  @@contexts = [] of Context
  @@random_order = false
  @@reporter = nil

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

  def self.configure_reporter(reporter)
    @@reporter = reporter
  end

  def self.reporter
    @@reporter
  end

  def self.run
    reporter_class = self.reporter
    unless reporter_class
      raise ReporterIsNotConfigured.new(
        "Please configure reporter with Spec2.configure_reporter(reporter)",
      )
    end

    reporter = reporter_class.new

    contexts.each do |context|
      context.examples.each do |high_example|
        example = high_example.example
        context.before_hooks.each do |hook|
          hook.call(example)
        end

        begin
          reporter.example_started(example)
          high_example.call
          context.after_hooks.each do |hook|
            hook.call(example)
          end
          reporter.example_succeeded(example)
        rescue e : ExpectationNotMet
          reporter.example_failed(example, e.with_example(example))
        rescue e
          reporter.example_errored(
            example,
            ExpectationNotMet.new(e.message, e).with_example(example),
          )
        end
      end
    end

    reporter.report
  end
end

Spec2.configure_reporter(Spec2::Reporters::Default)

at_exit do
  Spec2.run
end
