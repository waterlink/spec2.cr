module Spec2
  class Example
    @_description : String?

    @context : Context
    @what : String

    getter context, what
    def initialize(@context, @what)
    end

    def description
      @_description ||= "#{context.description} #{what}"
    end

    def run
    end

    def pending?
      false
    end

    def __spec2_clear_lets
    end
  end
end
