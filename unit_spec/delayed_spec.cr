require "./spec_helper"

module DelayedSpec
  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.describe "something with delayed" do
    let(answers) { {"life" => 74} }

    after { answers["life"] -= 12 }

    it "passes" do
      delayed { answers["life"].should H.eq(42) }
      answers["life"] -= 20
    end

    it "fails" do
      delayed { answers["life"].should H.eq(42) }
    end
  end

  describe "delayed statement" do
    passes = ::Spec2::Context.contexts[0].examples[0]
    fails = ::Spec2::Context.contexts[0].examples[1]

    it "runs after the example and after" do
      passes.run

      expect_raises ::Spec::AssertionFailed do
        fails.run
      end
    end
  end
end
