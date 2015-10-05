module Spec2
  class Context
    getter what, description, contexts, examples, _lets, parent_context, _before_hooks, _after_hooks

    def initialize(what, @parent_context)
      parent_what = parent_context.what
      what = "#{parent_what} #{what}" if parent_what

      @what = what
      @description = @what.to_s
      @examples = [] of HighExample
      @contexts = [] of Context
      @_lets = {} of String => LetWrapper
      @_before_hooks = [] of Hook
      @_after_hooks = [] of Hook
    end

    def reset
      lets.each do |_, wrapper|
        wrapper.let.reset
      end
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

    def lets
      @_realized_lets ||= parent_context.lets.merge(_lets)
    end

    def before_hooks
      @_realized_before_hooks ||=
        parent_context.before_hooks + _before_hooks
    end

    def after_hooks
      @_realized_after_hooks ||=
        parent_context.after_hooks + _after_hooks
    end
  end
end
