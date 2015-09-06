module Spec2
  class Let(T)
    getter name, block

    def initialize(@name, &@block : -> :: T)
    end

    def call
      block.call
    end
  end

  class LetWrapper
    getter let
    def initialize(@let)
    end
  end
end
