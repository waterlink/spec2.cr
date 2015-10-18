require "./spec_helper"

class EqualityExample
  def ==(other : self)
    true
  end

  def ==(other)
    false
  end
end

Spec2.describe Spec2::Matchers do
  describe "eq" do
    it "passes when values are equal" do
      expect(42).to eq(42)
      expect("hello world").to eq("hello world")
      expect(nil).to eq(nil)
      expect([] of Int32).to eq([] of Int32)
      expect({} of String => Int32).to eq({} of String => Int32)
      expect(EqualityExample.new).to eq(EqualityExample.new)
    end

    it "fails when values are not equal" do
      expect { expect(42).to eq(43) }.to raise_error(
        Spec2::ExpectationNotMet,
        eq("Expected to be equal:\n\t\tExpected:\t 43\n\t\tActual:\t\t 42\n")
      )
    end
  end
end
