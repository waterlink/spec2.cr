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
        .to eq(["#greet", "#stuff"])

      expect(runner.contexts.first.contexts.last.contexts.map &.description)
        .to eq(["more stuff"])
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
        .to eq(["when name is specified"])
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
        .to eq(["when name is specified"])

      expect(runner.contexts.first.contexts.first.contexts.map &.description)
        .to eq(["when name is invalid"])
    end
  end
end
