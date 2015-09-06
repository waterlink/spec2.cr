module Spec2
  class Hook
    getter block

    def initialize(&@block : (Example) ->)
    end

    def call(example)
      block.call(example)
    end
  end
end
