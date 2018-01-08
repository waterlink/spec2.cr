require "./spec_helper"

class SuccessfulMatcher
  include Spec2::Matcher

  def initialize()
  end

  def match(actual)
    true
  end

  def failure_message
    "Expected to be successful."
  end

  def failure_message_when_negated
    "Expected not to be successful."
  end

  def description
    "is always successful"
  end
end
Spec2.register_matcher(be_successful) { SuccessfulMatcher.new }

class UnsuccessfulMatcher
  include Spec2::Matcher

  def initialize()
  end

  def match(actual)
    false
  end

  def failure_message
    "Expected to be unsuccessful."
  end

  def failure_message_when_negated
    "Expected not to be unsuccessful."
  end

  def description
    "is never successful"
  end
end
Spec2.register_matcher(be_unsuccessful) { UnsuccessfulMatcher.new }

class TestObject
  def is_true?
    true
  end

  def is_false?
    false
  end

  def all_args?(a, b, c)
    !!a && !!b && !!c && !!yield
  end
end

Spec2.describe Spec2::Expectation do
  describe "to(...)" do
    it "passes when the matcher is successful" do
      expect("something").to be_successful
    end

    it "fails when the matcher is unsuccessful" do
      assert_expectation("Expected to be unsuccessful.") do
        expect("something").to be_unsuccessful
      end
    end
  end

  describe "not_to(...)" do
    it "passes when the matcher is unsuccessful" do
      expect("something").not_to be_unsuccessful
    end

    it "fails when the matcher is successful" do
      assert_expectation("Expected not to be successful.") do
        expect("something").not_to be_successful
      end
    end
  end

  describe "to_be.[...]" do
    describe "without args" do
      it "passes when it returns true" do
        expect(TestObject.new).to_be.is_true?
      end

      it "fails when it returns false" do
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> to be is_false\?\Z/) do
          expect(TestObject.new).to_be.is_false?
        end
      end
    end

    describe "with args" do
      it "passes when it returns true" do
        expect(TestObject.new).to_be.all_args? true, true, true { true }
      end

      it "fails when it returns false" do
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> to be all_args\? {false, true, true}\Z/) do
          expect(TestObject.new).to_be.all_args?(false, true, true) { true }
        end
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> to be all_args\? {true, false, true}\Z/) do
          expect(TestObject.new).to_be.all_args? true, false, true { true }
        end
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> to be all_args\? {true, true, false}\Z/) do
          expect(TestObject.new).to_be.all_args? true, true, false { true }
        end
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> to be all_args\? {true, true, true}\Z/) do
          expect(TestObject.new).to_be.all_args? true, true, true { false }
        end
      end
    end
  end

  describe "not_to_be.[...]" do
    describe "without args" do
      it "passes when it returns false" do
        expect(TestObject.new).not_to_be.is_false?
      end

      it "fails when it returns true" do
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> not to be is_true\?\Z/) do
          expect(TestObject.new).not_to_be.is_true?
        end
      end
    end

    describe "with args" do
      it "passes when it returns false" do
        expect(TestObject.new).not_to_be.all_args? false, true, true { true }
        expect(TestObject.new).not_to_be.all_args? true, false, true { true }
        expect(TestObject.new).not_to_be.all_args? true, true, false { true }
        expect(TestObject.new).not_to_be.all_args? true, true, true { false }
      end

      it "fails when it returns true" do
        assert_expectation(/\AExpected #<#{TestObject}:[^>]+> not to be all_args\? {true, true, true}\Z/) do
          expect(TestObject.new).not_to_be.all_args?(true, true, true) { true }
        end
      end
    end
  end

  def assert_expectation(message)
    begin
      yield
    rescue e : Spec2::ExpectationNotMet
      unless message === e.message
        raise Spec2::ExpectationNotMet.new("The message was expected to be #{message.inspect} but was #{e.message.inspect}.")
      end
    rescue e
      raise Spec2::ExpectationNotMet.new("Expected a Spec2::ExpectationNotMet exception to be thrown, but #{e.class} was thrown.")
    else
      raise Spec2::ExpectationNotMet.new("Expected a Spec2::ExpectationNotMet exception to be thrown, but nothing was thrown.")
    end
  end
end
