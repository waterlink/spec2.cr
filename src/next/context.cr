module Spec2
  class Context
    CURRENT = {"get" => ::Spec2::Context::Inside}
    DEFINED = {} of String => Bool

    def self.instance
      @@_instance ||= new(nil, "")
    end

    def self.contexts
      instance.contexts
    end

    def self.focused_contexts
      instance.focused_contexts
    end

    def self.__clear
      instance.__clear
    end

    getter what, description, focused
    def initialize(parent, @what, @focused = false)
      @description = what

      if parent && !parent.description.to_s.empty?
        @description = "#{parent.description} #{what}"
      end
    end

    def focused?
      focused
    end

    def contexts
      @_contexts ||= [] of Context
    end

    def focused_contexts
      contexts.select(&.focused?)
    end

    def examples
      @_examples ||= [] of Example
    end

    def focused_examples
      examples.select(&.focused?)
    end

    def __clear
      @_contexts = nil
    end

    module Inside
      include DSL

      @@__spec2_active_context = Context.instance
    end
  end
end
