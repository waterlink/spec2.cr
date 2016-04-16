module Spec2
  module Runner
    Factory.abstract
    abstract def run_context(reporter, order, context)
    abstract def current_context
    abstract def failed?
  end
end
