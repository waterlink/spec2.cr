module Spec2
  class Context
    getter what, description, contexts, examples, before_hooks, after_hooks, lets

    def initialize(@what)
      @description = @what.to_s
      @examples = [] of HighExample
      @contexts = [] of Context
      @lets = {} of String => LetWrapper
      @before_hooks = [] of Hook
      @after_hooks = [] of Hook
    end

    def contexts
      return _contexts.shuffle if Spec2.random_order?
      _contexts
    end

    def _contexts
      @contexts
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
