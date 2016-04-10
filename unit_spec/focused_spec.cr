require "./spec_helper"

Spec2::Context.__clear
evt = empty_evt
Spec2::DSL.describe "with focused example" do
  it "is not focused" do
  end

  fit "is focused" do
  end

  it "is yet another unfocused one" do
  end

  fit "is yet another focused one" do
  end
end

describe "focused example" do
  focused_a = ::Spec2::Context.contexts[0].examples[1]
  focused_b = ::Spec2::Context.contexts[0].examples[3]

  focused = ::Spec2::Context.contexts[0].focused_examples

  it "has only focused examples" do
    focused.should eq([focused_a, focused_b])
  end
end

Spec2::Context.__clear
evt = empty_evt
Spec2::DSL.describe "with focused context" do
  context "unfocused" do
  end

  fcontext "focused" do
  end

  describe "another unfocused" do
  end

  fdescribe "another focused" do
  end
end

describe "focused context" do
  focused_a = ::Spec2::Context.contexts[0].contexts[1]
  focused_b = ::Spec2::Context.contexts[0].contexts[3]

  focused = ::Spec2::Context.contexts[0].focused_contexts

  it "has only focused contexts" do
    focused.should eq([focused_a, focused_b])
  end

  it "has no focused root context" do
    ::Spec2::Context.focused_contexts.empty?.should eq(true)
  end
end


Spec2::Context.__clear
evt = empty_evt
Spec2::DSL.fdescribe "with focused root context" do
end

describe "focused root context" do
  root = ::Spec2::Context.contexts[0]
  focused = ::Spec2::Context.focused_contexts

  it "is correctly focused" do
    focused.should eq([root])
  end
end
