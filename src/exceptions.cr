module Spec2
  class ExpectationNotMet < Exception
    getter example

    def with_example(@example)
      self
    end
  end

  class ReporterIsNotConfigured < Exception
  end

  class RunnerIsNotConfigured < Exception
  end
end
