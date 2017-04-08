module Spec2
  class Context
    DEFINED = {} of String => Bool

    def self.instance
      @@_instance ||= new(nil, "")
    end

    def self.contexts
      instance.contexts
    end

    def self.__clear
      instance.__clear
    end

    getter what, description
    def initialize(parent, @what : String)
      @description = what

      if parent && !parent.description.to_s.empty?
        @description = "#{parent.description} #{what}"
      end
    end

    def initialize(parent, what)
      initialize(parent, what.to_s)
    end

    def contexts
      @_contexts ||= [] of Context
    end

    def examples
      @_examples ||= [] of Example
    end

    def global_befores
      @_global_befores ||= [] of Proc(Nil)
    end

    def add_global_before(&blk : Proc(Nil))
      global_befores << blk
    end

    def __clear
      @_contexts = nil
      @_global_befores = [] of Proc(Nil)
    end
  end
end
