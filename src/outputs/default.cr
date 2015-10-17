module Spec2
  module Outputs
    class Default < Output
      COLORS = {
        success: :green,
        failure: :red,
      }

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
