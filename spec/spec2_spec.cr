require "./spec_helper"

Spec2.random_order

class Greeting
  getter exclamation

  def initialize(@exclamation)
  end

  def for(name)
    "#{exclamation}, #{name}"
  end
end

Spec2.describe Greeting do
  it "works" do
    expect(Greeting.new("hello").for("world"))
      .to eq("hello, world")
  end

  it "doesnt" do
    expect(2+2).not_to eq(4)
  end

  it "fails" do
    raise "Hello Error"
  end
end
