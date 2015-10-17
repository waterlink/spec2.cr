module Spec2::GlobalDSL
  macro describe(what, file = __FILE__, line = __LINE__, &block)
    ::Spec2.describe({{what}}, {{file}}, {{line}}) {{block}}
  end
end
