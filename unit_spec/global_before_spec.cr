require "./spec_helper"

module GlobalBeforeSpec

  Spec2::Context.__clear
  evt = empty_evt
  Spec2::DSL.global_before do
    evt << :global_before
  end
  Spec2::DSL.global_before do
    evt << :global_before_2
  end
  Spec2::DSL.describe "something with it and global before" do
    evt << :described_something

    it "works" do
      H.evt << :it_works
    end

    it "also works" do
      H.evt << :it_also_works
    end
  end

  describe "global before" do
    examples = Spec2::Context.contexts[0].examples

    it "does not run global befores at definition stage" do
      evt.should H.eq([:described_something])
    end

    it "runs 'global before's before each test" do
      examples.each &.run

      evt.should H.eq([
        :described_something,
        :global_before,
        :global_before_2,
        :it_works,
        :global_before,
        :global_before_2,
        :it_also_works,
      ])
    end
  end

end
