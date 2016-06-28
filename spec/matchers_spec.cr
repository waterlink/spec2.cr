require "./spec_helper"

class EqualityExample
  def ==(other : self)
    true
  end

  def ==(other)
    false
  end
end

class Greeting
  def correct?(word, name, greeting)
    greeting == "#{word}, #{name}!"
  end
end

class ErrorExample < Exception
end

class AnotherErrorExample < Exception
end

Spec2.describe Spec2::Matchers do
  describe "eq(...)" do
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

  describe "raise_error([... [, ...]])" do
    context "when error is expected" do
      context "when there is no error" do
        it "fails" do
          expect { expect { 42 }.to raise_error(ErrorExample) }.to raise_error(
            Spec2::ExpectationNotMet,
            eq("Expected block to fail with ErrorExample \n        But got: no error\n        ")
          )
        end
      end

      context "when there is an error of different class" do
        it "fails" do
          expect {
            expect { raise AnotherErrorExample.new("another error") }.to raise_error(ErrorExample)
          }.to raise_error(
            Spec2::ExpectationNotMet,
            eq("Expected block to fail with ErrorExample \n        But got: AnotherErrorExample: another error\n        ")
          )
        end
      end

      context "when there is an error of the same class" do
        it "passes" do
          expect { raise ErrorExample.new("some error") }.to raise_error(ErrorExample)
        end
      end

      context "and message matcher provided" do
        context "when error message does not match" do
          it "fails" do
            expect {
              expect { raise ErrorExample.new("another error") }.to raise_error(ErrorExample, eq("some error"))
            }.to raise_error(
              Spec2::ExpectationNotMet,
              eq("Expected block to fail with ErrorExample (== \"some error\")\n        But got: ErrorExample: another error\n        Expected to be equal:\n\t\tExpected:\t \"some error\"\n\t\tActual:\t\t \"another error\"\n"),
            )
          end
        end

        context "when error message matches" do
          it "passes" do
            expect { raise ErrorExample.new("some error") }.to raise_error(ErrorExample, eq("some error"))
          end
        end
      end
    end
  end

  describe "be(...)" do
    context "when things are not equal" do
      it "fails" do
        expect {
          expect([] of String).to be(EqualityExample.new)
        }.to raise_error(
          Spec2::ExpectationNotMet,
          match(/Expected to be the same:\n        Expected: #<EqualityExample:.+>\n        Actual:   \[\]/),
        )
      end
    end

    context "when things are equal" do
      context "and different" do
        it "fails" do
          expect {
            expect(EqualityExample.new).to be(EqualityExample.new)
          }.to raise_error(
            Spec2::ExpectationNotMet,
            match(/Expected to be the same:\n        Expected: #<EqualityExample:.+>\n        Actual:   #<EqualityExample:.+>/),
          )
        end
      end

      context "and same" do
        subject { EqualityExample.new }

        it "passes" do
          expect(subject).to eq(subject)
        end
      end
    end
  end

  describe "be_true" do
    context "when value is true" do
      it "passes" do
        expect(true).to be_true
      end
    end

    context "when value is false" do
      it "fails" do
        expect {
          expect(false).to be_true
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t true\n\t\tActual:\t\t false\n",
        )
      end
    end

    context "when value is nil" do
      it "fails" do
        expect {
          expect(nil).to be_true
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t true\n\t\tActual:\t\t nil\n",
        )
      end
    end

    context "when value is of different type" do
      it "fails" do
        expect {
          expect("hello world").to be_true
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t true\n\t\tActual:\t\t \"hello world\"\n",
        )
      end
    end
  end

  describe "be_false" do
    context "when value is true" do
      it "fails" do
        expect {
          expect(true).to be_false
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t false\n\t\tActual:\t\t true\n",
        )
      end
    end

    context "when value is false" do
      it "passes" do
        expect(false).to be_false
      end
    end

    context "when value is nil" do
      it "fails" do
        expect {
          expect(nil).to be_false
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t false\n\t\tActual:\t\t nil\n",
        )
      end
    end

    context "when value is of different type" do
      it "fails" do
        expect {
          expect("hello world").to be_false
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t false\n\t\tActual:\t\t \"hello world\"\n",
        )
      end
    end
  end

  describe "be_truthy" do
    context "when value is true" do
      it "passes" do
        expect(true).to be_truthy
      end
    end

    context "when value is false" do
      it "fails" do
        expect {
          expect(false).to be_truthy
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected false to be truthy",
        )
      end
    end

    context "when value is nil" do
      it "fails" do
        expect {
          expect(nil).to be_truthy
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected nil to be truthy",
        )
      end
    end

    context "when value is of different type" do
      it "passes" do
        expect("hello world").to be_truthy
      end
    end
  end

  describe "be_falsey" do
    context "when value is true" do
      it "fails" do
        expect {
          expect(true).to be_falsey
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected true to be falsey",
        )
      end
    end

    context "when value is false" do
      it "passes" do
        expect(false).to be_falsey
      end
    end

    context "when value is nil" do
      it "passes" do
        expect(nil).to be_falsey
      end
    end

    context "when value is of different type" do
      it "fails" do
        expect {
          expect("hello world").to be_falsey
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected \"hello world\" to be falsey",
        )
      end
    end
  end

  describe "be_nil" do
    context "when value is true" do
      it "fails" do
        expect {
          expect(true).to be_nil
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t nil\n\t\tActual:\t\t true\n",
        )
      end
    end

    context "when value is false" do
      it "fails" do
        expect {
          expect(false).to be_nil
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t nil\n\t\tActual:\t\t false\n",
        )
      end
    end

    context "when value is nil" do
      it "passes" do
        expect(nil).to be_nil
      end
    end

    context "when value is of different type" do
      it "fails" do
        expect {
          expect("hello world").to be_nil
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be equal:\n\t\tExpected:\t nil\n\t\tActual:\t\t \"hello world\"\n",
        )
      end
    end
  end

  describe "be_close(expected, delta)" do
    context "when equal" do
      it "passes" do
        expect(42).to be_close(42, 0.01)
      end
    end

    context "when in delta-proximity" do
      it "passes" do
        expect(42.005).to be_close(42, 0.01)
        expect(41.995).to be_close(42, 0.01)
      end
    end

    context "when out of delta-proximity" do
      it "fails" do
        expect {
          expect(42.05).to be_close(42, 0.01)
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected to be close:\n        Expected:  42\n        Actual:    42.05\n        Max-delta: 0.01\n        Delta:     0.049999999999997158"
        )
      end
    end
  end

  describe ".to_be" do
    describe "< ..." do
      context "when is less than expected" do
        it "passes" do
          expect(42).to_be < 45
        end
      end

      context "when is more than expected" do
        it "fails" do
          expect {
            expect(55).to_be < 45
          }.to raise_error(
            Spec2::ExpectationNotMet,
            "Expected 55 to be < 45",
          )
        end
      end

      context "when is equal expected" do
        it "fails" do
          expect {
            expect(45).to_be < 45
          }.to raise_error(
            Spec2::ExpectationNotMet,
            "Expected 45 to be < 45",
          )
        end
      end
    end

    describe ".even?" do
      context "when is even" do
        it "passes" do
          expect(42).to_be.even?
        end
      end

      context "when is not even" do
        it "fails" do
          expect {
            expect(45).to_be.even?
          }.to raise_error(
            Spec2::ExpectationNotMet,
            "Expected 45 to be even?",
          )
        end
      end
    end

    context "other types" do
      describe ".correct?(word, name, greeting)" do
        context "when is correct" do
          it "passes" do
            expect(Greeting.new).to_be.correct?("hello", "world", "hello, world!")
          end
        end

        context "when is not correct" do
          it "fails" do
            expect {
              expect(Greeting.new).to_be.correct?("hello", "john", "hello, world!")
            }.to raise_error(
              Spec2::ExpectationNotMet,
              match(/Expected #<Greeting:.+> to be correct\? {"hello", "john", "hello, world!"}/),
            )
          end
        end
      end
    end
  end

  describe ".not_to_be" do
    describe "< ..." do
      context "when is less than expected" do
        it "fails" do
          expect {
            expect(42).not_to_be < 45
          }.to raise_error(
            Spec2::ExpectationNotMet,
            "Expected 42 not to be < 45",
          )
        end
      end

      context "when is more than expected" do
        it "passes" do
          expect(55).not_to_be < 45
        end
      end

      context "when is equal expected" do
        it "passes" do
          expect(45).not_to_be < 45
        end
      end
    end

    describe ".even?" do
      context "when is even" do
        it "fails" do
          expect {
            expect(42).not_to_be.even?
          }.to raise_error(
            Spec2::ExpectationNotMet,
            "Expected 42 not to be even?",
          )
        end
      end

      context "when is not even" do
        it "passes" do
          expect(45).not_to_be.even?
        end
      end
    end

    context "other types" do
      describe ".correct?(word, name, greeting)" do
        context "when is correct" do
          it "fails" do
            expect {
              expect(Greeting.new).not_to_be.correct?("hello", "world", "hello, world!")
            }.to raise_error(
              Spec2::ExpectationNotMet,
              match(/Expected #<Greeting:.+> not to be correct\? {"hello", "world", "hello, world!"}/),
            )
          end
        end

        context "when is not correct" do
          it "passes" do
            expect(Greeting.new).not_to_be.correct?("hello", "john", "hello, world!")
          end
        end
      end
    end
  end

  describe "be_a(...)" do
    context "when type matches" do
      it "passes" do
        expect(42).to be_a(Int32)
        expect("hello world").to be_a(String)
        expect(Greeting.new).to be_a(Greeting)
      end
    end

    context "when type does not match" do
      it "fails" do
        expect {
          expect(42).to be_a(String)
        }.to raise_error(
          Spec2::ExpectationNotMet,
          "Expected 42 to be a String",
        )
      end
    end
  end

  class DescribedClass
    @foo = "bar"

    def foo
      @foo
    end
  end

  describe DescribedClass do
    context "when describe uses a class" do
      it "has the described_class attribute" do
        expect(described_class).to eq(DescribedClass)
        expect(described_class.new.foo).to eq("bar")
      end
    end
  end

  describe (2 + 2) do
    context "when describe uses literal expression" do
      it "fails" do
        expect {
          expect(described_class).to eq(4)
        }.to raise_error(
          Exception,
          "2 + 2 is expected to be a Class, not Int32"
        )
      end
    end
  end
end
