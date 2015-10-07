module Spec2
  class Example
    getter ctx, what, file, line, block
    def initialize(@ctx, @what, @file, @line, &@block)
    end

    def call
      block.call
    end

    def description
      (ctx.instance.description + " " + what.to_s).strip
    end
  end
end
