module Spec2
  class ExpectationNotMet < Exception
    getter example : Example?

    def with_example(@example)
      self
    end
  end

  class ReporterIsNotConfigured < Exception
  end

  class RunnerIsNotConfigured < Exception
  end

  class OrderIsNotConfigured < Exception
  end

  class OutputIsNotConfigured < Exception
  end
end
