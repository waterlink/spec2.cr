module Spec2
  abstract class Runner
    abstract def run_context(context, reporter)
    abstract def current_context
  end
end
