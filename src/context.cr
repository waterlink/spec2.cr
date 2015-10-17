module Spec2
  class Context
    extend Matchers

    macro it(what, file = __FILE__, line = __LINE__, &block)
      instance.examples << ::Spec2::Example.new(self, {{what}}, {{file}}, {{line}}) {{block}}
    end

    macro describe(what, file = __FILE__, line = __LINE__, &block)
      ::Spec2.describe({{what}}, {{file}}, {{line}}) {{block}}
    end

    macro context(what, file = __FILE__, line = __LINE__, &block)
      describe({{what}}, {{file}}, {{line}}) {{block}}
    end

    def self.before(&block)
      instance.before(&block)
    end

    def self.after(&block)
      instance.after(&block)
    end

    macro let(decl, &block)
      {% LETS << decl.id.stringify %}

      def {{decl.id}}
        @_let_{{decl.id}} ||= {{decl.id}}!
      end

      def {{decl.id}}!
        {{block.body}}
      end

      def self.{{decl.id}}
        (instance as self).{{decl.id}}
      end

      def clear_lets
        {% for name in LETS %}
             @_let_{{name.id}} = nil
        {% end %}
      end
    end

    def self.instance
      ContextRegistry.instance_of(self)
    end

    def self.parent
      ContextRegistry.parent_of(self)
    end

    def self.expect(actual)
      Expectation.new(actual)
    end

    def before(&block)
      _before_hooks << block
    end

    def after(&block)
      _after_hooks << block
    end

    def before_hooks
      parent_before_hooks + _before_hooks
    end

    def after_hooks
      parent_after_hooks + _after_hooks
    end

    def parent_before_hooks
      return [] of (->) unless parent = self.class.parent
      parent.instance.before_hooks
    end

    def parent_after_hooks
      return [] of (->) unless parent = self.class.parent
      parent.instance.after_hooks
    end

    def _before_hooks
      @_before_hooks ||= [] of ->
    end

    def _after_hooks
      @_after_hooks ||= [] of ->
    end

    def examples
      @_examples ||= [] of Example
    end

    def contexts
      @_contexts ||= [] of Context
    end

    def clear_lets
    end

    def description
      ""
    end

    def description
      ""
    end

    def what
      ""
    end

    def file
      "spec2_root_context"
    end

    def line
      1
    end
  end

  class DumbContextSubclass < Context
  end

  class ContextRegistry
    @@contexts = {Context => Context.new, DumbContextSubclass => DumbContextSubclass.new}
    @@parents = {Context => Context, DumbContextSubclass => DumbContextSubclass}

    def self.clear
      @@contexts.clear
      @@parents.clear
    end

    def self.instance_of(klass)
      @@contexts[klass] ||= klass.new
    end

    def self.register_parent(klass, parent)
      @@parents[klass] = parent
    end

    def self.parent_of(klass)
      @@parents[klass]?
    end
  end

  ContextRegistry.clear
end
