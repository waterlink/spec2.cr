module Spec2
  class Example
    getter context, what, focused
    def initialize(@context, @what, @focused = false, &@blk : ->)
    end

    def description
      @_description ||= "#{context.description} #{what}"
    end

    def run
      @blk.call
    end

    def __spec2_clear_lets
    end

    def focused?
      focused
    end
  end
end
