require "./spec_helper"

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
end

Spec2.run
