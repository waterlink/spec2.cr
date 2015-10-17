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

    macro before(&block)
    end

    macro after(&block)
    end

    macro let(decl, &block)
      def {{decl.id}}
        @_{{decl.id}} ||= {{decl.id}}!
      end

      def {{decl.id}}!
        {{block.body}}
      end

      def self.{{decl.id}}
        instance.{{decl.id}}
      end
    end

    def self.instance
      ContextRegistry.instance_of(self)
    end

    def self.expect(actual)
      Expectation.new(actual)
    end

    def examples
      @_examples ||= [] of Example
    end

    def contexts
      @_contexts ||= [] of Context
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

    def self.clear
      @@contexts.clear
    end

    def self.instance_of(klass)
      @@contexts[klass] ||= klass.new
    end
  end

  ContextRegistry.clear
end
