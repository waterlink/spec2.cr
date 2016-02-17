require "spec"

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
end
