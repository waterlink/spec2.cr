module Spec2
  class Let(T)
    getter name, block

    def initialize(@name, &@block : -> :: T)
    end

    def call
      @_result ||= block.call
    end

    def reset
      @_result = nil
    end
  end

  class LetWrapper
    getter let
    def initialize(@let)
    end
  end
end
