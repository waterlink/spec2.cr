require "spec"
require "../src/next"

def empty_evt
  H.clear
  H.evt
end

module H
  def self.evt
    @@_evt ||= [] of Symbol
  end

  def self.clear
    @@_evt = nil
  end

  def self.eq(expected)
    Spec::EqualExpectation.new(expected)
  end
end
