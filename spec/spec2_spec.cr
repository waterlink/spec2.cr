require "./spec_helper"

class Greeting; end

module Spec2::Specs
  include Spec2::Macros

  describe "#describe" do
    it "describes string" do
      runner = with_runner do
        describe "some string here" do
        end
      end

      expect(runner.contexts.map &.description)
        .to eq(["some string here"])
    end

    it "describes some class" do
      runner = with_runner do
        describe Greeting do
        end
      end

      expect(runner.contexts.map &.description)
        .to eq(["Greeting"])
    end

    it "should be possible to use nested describe" do
      runner = with_runner do
        describe Greeting do
          describe "#greet" do
          end

          describe "#stuff" do
            describe "more stuff" do
            end
          end
        end
      end

      expect(runner.contexts.map &.description)
        .to eq(["Greeting"])

      expect(runner.contexts.first.contexts.map &.description)
        .to eq(["Greeting #greet", "Greeting #stuff"])

      expect(runner.contexts.first.contexts.last.contexts.map &.description)
        .to eq(["Greeting #stuff more stuff"])
    end
  end

  describe "#context" do
    it "narrows context with string" do
      runner = with_runner do
        describe Greeting do
          context "when name is specified" do
          end
        end
      end

      expect(runner.contexts.map &.description)
        .to eq(["Greeting"])

      expect(runner.contexts.first.contexts.map &.description)
        .to eq(["Greeting when name is specified"])
    end

    it "allows nesting" do
      runner = with_runner do
        describe Greeting do
          context "when name is specified" do
            context "when name is invalid" do
            end
          end
        end
      end

      expect(runner.contexts.map &.description)
        .to eq(["Greeting"])

      expect(runner.contexts.first.contexts.map &.description)
        .to eq(["Greeting when name is specified"])

      expect(runner.contexts.first.contexts.first.contexts.map &.description)
        .to eq(["Greeting when name is specified when name is invalid"])
    end
  end

  describe "#it" do
    it "defines an example" do
      runner = with_runner do
        describe "a thing" do
          it "does something" do
            expect(2 + 2).to eq(4)
          end
        end
      end

      expect(runner.contexts.first.examples.map &.example.description)
        .to eq(["a thing does something"])
    end

    context "when is in nested context" do
      it "has proper description" do
        runner = with_runner do
          describe "a thing" do
            context "when moon is full" do
              it "does something else" do
                expect(2 + 2).to eq(5)
              end
            end
          end
        end

        expect(runner.contexts.first.contexts.first.examples.map &.example.description)
          .to eq(["a thing when moon is full does something else"])
      end
    end

    context "when run" do
      it "sends proper events to reporter" do
        runner = with_runner do
          describe "a thing" do
            it "does something" do
              expect(2 + 2).to eq(4)
            end
          end
        end

        runner.run

        received = TestReporter.new.received
        expect(received.size).to eq(3)

        expect(received[0].event).to eq(:example_started)
        expect(received[0].example.not_nil!.description).to eq("a thing does something")

        expect(received[1].event).to eq(:example_succeeded)
        expect(received[1].example.not_nil!.description).to eq("a thing does something")

        expect(received[2].event).to eq(:report)
      end

      context "when failed" do
        it "sends additionally :example_failed event to reporter" do
          runner = with_runner do
            describe "a thing" do
              context "when moon is full" do
                it "does something else" do
                  expect(2 + 2).to eq(5)
                end
              end
            end
          end

          runner.run

          received = TestReporter.new.received
          expect(received.size).to eq(3)

          expect(received[0].event).to eq(:example_started)
          expect(received[0].example.not_nil!.description).to eq("a thing when moon is full does something else")

          expect(received[1].event).to eq(:example_failed)
          expect(received[1].example.not_nil!.description).to eq("a thing when moon is full does something else")
          expect(received[1].exception.not_nil!.message).to eq("Expected 4 to be equal to 5")

          expect(received[2].event).to eq(:report)
        end
      end

      context "when errored" do
        it "sends additionally :example_failed event to reporter" do
          runner = with_runner do
            describe "a thing" do
              context "when moon is full" do
                it "fails" do
                  raise Exception.new("Unable to do stuff")
                end
              end
            end
          end

          runner.run

          received = TestReporter.new.received
          expect(received.size).to eq(3)

          expect(received[0].event).to eq(:example_started)
          expect(received[0].example.not_nil!.description).to eq("a thing when moon is full fails")

          expect(received[1].event).to eq(:example_errored)
          expect(received[1].example.not_nil!.description).to eq("a thing when moon is full fails")
          expect(received[1].exception.not_nil!.message).to eq("Unable to do stuff")

          expect(received[2].event).to eq(:report)
        end
      end
    end
  end
end
