require "./matchers/*"
require "./exceptions"
require "./expectation"
require "./example"
require "./let"
require "./hook"
require "./context"
require "./macro"

module Spec2
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
