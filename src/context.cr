module Spec2
  class Context
    getter what, description, examples, before_hooks, after_hooks, lets

    def initialize(@what)
      @description = @what.to_s
      @examples = [] of HighExample
      @lets = {} of String => LetWrapper
      @before_hooks = [] of Hook
      @after_hooks = [] of Hook
    end

    def examples
      return _examples.shuffle if Spec2.random_order?
      _examples
    end

    def _examples
      @examples
    end
  end
end
