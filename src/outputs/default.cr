module Spec2
  module Outputs
    class Default
      include Output
      extend Output::Factory

      COLORS = {
        success: :green,
        failure: :red,
        pending: :yellow,
      }

      def self.build
        new
      end

      def print(style, string)
        return io_print(string) if style == :normal
        io_print(string.colorize(COLORS[style]))
      end

      private def io_print(string)
        STDOUT.print(string)
      end
    end
  end
end
