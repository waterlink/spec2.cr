module Spec2
  module DSL
    include Matchers
    extend Matchers

    module HasActiveContext
      macro included
        @@__spec2_active_context : ::Spec2::Context
        def self.__spec2_active_context
          @@__spec2_active_context
        end
      end
    end

    module Spec2___
      include ::Spec2::DSL
      include ::Spec2::DSL::HasActiveContext

      @@__spec2_active_context = ::Spec2::Context.instance

      def __spec2_before_hook
      end

      def __spec2_after_hook
      end

      def __spec2_run_lets!
      end

      def __spec2_clear_lets
      end
    end

    SPEC2_CONTEXT = ::Spec2::DSL::Spec2___
    SPEC2_FULL_CONTEXT = ":root"

    macro describe(what, file = __FILE__, line = __LINE__, &blk)
      {% if SPEC2_FULL_CONTEXT == ":root" %}
        module Spec2___Root
        @@__spec2_active_context : ::Spec2::Context
        @@__spec2_active_context = ::Spec2::Context.instance
        ::Spec2::DSL.context(
      {% else %}
        context(
      {% end %}
        {{what}}, {{file}}, {{line}}
      ) {{blk}}

      {% if SPEC2_FULL_CONTEXT == ":root" %}
        {{:end.id}}
      {% end %}
    end

    macro context(what, file = __FILE__, line = __LINE__, &blk)
      {% name = what.id.stringify.gsub(/[^\w]/, "_") %}
      {% name = ("Spec2__" + name.camelcase).id %}

      {% full_name = "#{SPEC2_FULL_CONTEXT.id} -> #{what.id} (#{file.id}:#{line.id})" %}

      %current_context = @@__spec2_active_context
      module {{name.id}}
        include {{SPEC2_CONTEXT}}
        include ::Spec2::DSL::HasActiveContext

        @@__spec2_active_context = ::Spec2::Context
          .new({{SPEC2_CONTEXT}}.__spec2_active_context, {{what}})

        {% unless ::Spec2::Context::DEFINED[full_name] == true %}
          SPEC2_FULL_CONTEXT = {{full_name}}
          SPEC2_CONTEXT = {{name.id}}
          LETS = {} of String => Int32
          LETS_BANG = {} of String => Int32
          BEFORES = [] of Int32
          AFTERS = [] of Int32
          ITS = {} of String => Int32
          PENDING_ITS = {} of String => Bool
          {% ::Spec2::Context::DEFINED[full_name] = true %}
        {% end %}

        {% unless what.is_a?(StringLiteral) %}
          def described_class
            unless ({{what.id}}).is_a?(Class)
              raise "#{ {{what.id.stringify}} } is expected to be a Class, not #{typeof({{what.id}}) }"
            end
            {{what.id}}
          end
        {% end %}

        __spec2_sanity_checks({{name}}, {{full_name}})

        (%current_context ||
         ::Spec2::Context.instance)
          .contexts << @@__spec2_active_context

        {{blk.body}}

        __spec2_def_lets
        __spec2_def_hooks
        __spec2_def_its
      end
    end

    macro __spec2_sanity_checks(name, full_name)
      {% if name.id.stringify != SPEC2_CONTEXT.id.stringify %}
        {% raise "Assertion failed: expected SPEC2_CONTEXT to equal #{name.id} but got #{SPEC2_CONTEXT}
         Full name: #{full_name.id}" %}
      {% end %}
    end

    macro it(what, &blk)
      {% ITS[what] = blk %}
      {% PENDING_ITS[what] = false %}
    end

    macro pending(what, &blk)
      {% ITS[what] = blk %}
      {% PENDING_ITS[what] = true %}
    end

    macro __spec2_def_its
      {% for what in ITS %}
        __spec2_def_it({{what}})
      {% end %}
    end

    macro __spec2_def_it(what)
      {% blk = ITS[what] %}

      {% name = what.id.stringify.gsub(/[^\w]/, "_") %}
      {% name = ("Spec2__" + name.camelcase).id %}

      class {{name.id}} < ::Spec2::Example
        include {{SPEC2_CONTEXT}}

        def initialize(@context)
          @what = {{what}}
        end

        {% if PENDING_ITS[what] == false %}
        def run
          __spec2_delayed = [] of ->

          Spec2::Context.instance.global_befores.each &.call
          __spec2_before_hook
          __spec2_run_lets!
          {{blk.body}}

        ensure
          __spec2_after_hook
          __spec2_delayed.not_nil!.each &.call
        end

        def pending?
          false
        end
        {% else %}
        def run
        end

        def pending?
          true
        end
        {% end %}
      end

      %current_context = (@@__spec2_active_context ||
                          ::Spec2::Context.instance)
      %current_context
        .examples << {{name.id}}.new(%current_context)
    end

    macro let(name, &blk)
      {% LETS[name] = blk %}
    end

    macro let!(name, &blk)
      {% LETS_BANG[name] = 1 %}
      let({{name}}) {{blk}}
    end

    macro __spec2_def_lets
      {% for what in LETS %}
        __spec2_def_let({{what}})
      {% end %}

      def __spec2_run_lets!
        super
        {% for what in LETS_BANG %}
          {{what.id}}
        {% end %}
      end

      def __spec2_clear_lets
        super
        {% for what in LETS %}
          __spec2_clear_specific_let({{what}})
        {% end %}
      end
    end

    macro __spec2_clear_specific_let(name)
      @_{{name.id}} = nil
    end

    module LetProtocol
      abstract def unwrap
    end

    class Let(T)
      include LetProtocol

      @unwrap : T
      getter unwrap

      def initialize(&block : -> T)
        @unwrap = block.call
      end
    end

    macro __spec2_def_let(name)
      {% blk = LETS[name] %}

      @_{{name.id}} : LetProtocol?

      def {{name.id}}
        (@_{{name.id}} ||= {{name.id}}!).unwrap.as(typeof(__spec2_well_typed_let__{{name.id}}))
      end

      def {{name.id}}!
        Let.new do
          __spec2_well_typed_let__{{name.id}}
        end
      end

      def __spec2_well_typed_let__{{name.id}}
        {{blk.body}}
      end
    end

    macro subject(&blk)
      {% if blk.is_a?(Nop) %}
        __spec2_subject
      {% else %}
        let(__spec2_subject) {{blk}}
      {% end %}
    end

    macro subject(name, &blk)
      let({{name}}) {{blk}}
    end

    macro subject!(&blk)
      {% LETS_BANG["__spec2_subject".id] = 1 %}
      subject {{blk}}
    end

    macro subject!(name, &blk)
      let!({{name}}) {{blk}}
    end

    macro before(&blk)
      {% BEFORES << blk %}
    end

    macro after(&blk)
      {% AFTERS << blk %}
    end

    macro global_before(&blk)
      Spec2::Context.instance.add_global_before {{blk}}
    end

    macro __spec2_def_hooks
      def __spec2_before_hook
        super
        {% for blk in BEFORES %}
          {{blk.body}}
        {% end %}
      end

      def __spec2_after_hook
        super
        {% for blk in AFTERS %}
          {{blk.body}}
        {% end %}
      end
    end

    macro delayed(&blk)
      __spec2_delayed << -> {{blk}}
    end

    def expect(actual)
      Expectation.new(actual)
    end

    def expect(&block)
      Expectation.new(block)
    end
  end
end
