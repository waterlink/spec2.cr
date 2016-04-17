module Spec2
  module Outputs
    class Nocolor
      include Output
      extend Output::Factory

      def self.build
        new
      end

      def print(style, string)
        STDOUT.print(string)
      end
    end
  end

  def self.nocolor
    configure_output(Outputs::Nocolor)
  end
end
