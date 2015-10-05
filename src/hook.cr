module Spec2
  class Hook
    getter block

    def initialize(&@block : (Example, Context) ->)
    end

    def call(example, context)
      block.call(example, context)
    end
  end
end
