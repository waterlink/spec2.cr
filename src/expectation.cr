module Spec2
  module ExpectationProtocol
    abstract def callback(ok, failure_message, failure_message_when_negated)
  end

  class Expectation(T)
    include ExpectationProtocol

    getter actual
    getter matcher : Matcher?
    getter negative : Bool

    def initialize(@actual : T)
      @negative = false
    end

    def to(@matcher)
      return if matcher.match(actual)
      raise ExpectationNotMet.new(matcher.failure_message)
    end

    def to_be
      Matchers::BeRecorder.new(actual, self)
    end

    def not_to(@matcher)
      return unless matcher.match(actual)
      raise ExpectationNotMet.new(matcher.failure_message_when_negated)
    end

    def not_to_be
      @negative = true
      Matchers::BeRecorder.new(actual, self)
    end

    def callback(ok, failure_message, failure_message_when_negated)
      return negative_callback(ok, failure_message_when_negated) if negative
      positive_callback(ok, failure_message)
    end

    def positive_callback(ok, message)
      return if ok
      raise ExpectationNotMet.new(message)
    end

    def negative_callback(ok, message)
      return unless ok
      raise ExpectationNotMet.new(message)
    end
  end
end
