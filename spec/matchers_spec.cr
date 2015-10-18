require "./spec_helper"

class EqualityExample
  def ==(other : self)
    true
  end

  def ==(other)
    false
  end
end

class ErrorExample < Exception
end

class AnotherErrorExample < Exception
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

  describe "raise_error" do
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

  describe "be" do
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
end
