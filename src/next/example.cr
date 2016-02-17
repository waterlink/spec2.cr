module Spec2
  class Example
    getter context, what
    def initialize(@context, @what, &@blk : ->)
    end

    def description
      @_description ||= "#{context.description} #{what}"
    end

    def run
      @blk.call
    end

    def __spec2_clear_lets
    end
  end
end
