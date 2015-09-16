module Spec2
  module Macros
    macro describe(what, &block)
      context = ::Spec2::Context.new({{what}}, Spec2.current_context)

      Spec2.current_context._contexts << context

      %old_context = Spec2.current_context
      Spec2.current_context = context
      {{block.body}}
      Spec2.current_context = %old_context

      if %old_context.is_a?(::Spec2::Context)
        context = %old_context 
      end
    end

    macro context(what, &block)
      describe({{what}}) {{block}}
    end

    macro it(description, &block)
      example = ::Spec2::Example.new(context, context.what, {{description}})
      puts "adding #{example.inspect}"
      context._examples << ::Spec2::HighExample.new(example) do |context|
        example.call {{block}}
      end
      puts "#{context.description} :: added #{example.description} -> #{context._examples.size} vs #{context.examples.size}"
    end

    macro it(&block)
      it({{block.body.stringify}}) {{block}}
    end

    macro before(&block)
      hook = ::Spec2::Hook.new do |example, context|
        example.call {{block}}
      end
      context._before_hooks << hook
    end

    macro after(&block)
      hook = ::Spec2::Hook.new do |example, context|
        example.call {{block}}
      end
      context._after_hooks << hook
    end

    macro let(name, &block)
      a_let = ::Spec2::Let({{name.type.id}}).new({{name.stringify}}) {{block}}
      context.lets[{{name.var.stringify}}] = ::Spec2::LetWrapper.new(a_let)
      macro {{name.var.id}}
        context.lets[{{name.var.stringify}}].not_nil!.let.call as {{name.type.id}}
      end
    end

    macro let!(name, &block)
      let({{name}}) {{block}}
      before { {{name.var.id}} }
    end

    macro _subject(type, name, &block)
      {% if name.is_a?(DeclareVar) %}
         {{type}}({{name}}) {{block}}
      {% else %}
         {{type}}(subject :: {{name.id}}) {{block}}
      {% end %}
    end

    macro subject(name, &block)
      _subject(let, {{name}}) {{block}}
    end

    macro subject!(name, &block)
      _subject(let!, {{name}}) {{block}}
    end

    macro is_expected
      expect(subject)
    end
  end
end
