module Spec2
  class HighRunner
    getter reporter, runner, order, root, exit_code
    getter! current_runner
    def initialize(@root)
      @exit_code = 0
    end

    def contexts
      [root]
    end

    def configure_reporter(@reporter)
    end

    def configure_runner(@runner)
    end

    def configure_order(@order)
    end

    def want_exit(@exit_code)
    end

    def run
      reporter_class = self.reporter
      unless reporter_class
        raise ReporterIsNotConfigured.new(
          "Please configure reporter with Spec2.configure_reporter(reporter)",
        )
      end

      runner_class = self.runner
      unless runner_class
        raise RunnerIsNotConfigured.new(
          "Please configure runner with Spec2.configure_runner(runner)",
        )
      end

      order_class = self.order
      unless order_class
        raise OrderIsNotConfigured.new(
          "Please configure order with Spec2.configure_order(order)",
        )
      end

      reporter = reporter_class.new
      @current_runner = runner_class.new
      order = order_class.new

      current_runner.run_context(reporter, order, root)
      reporter.report

      want_exit(1) if current_runner.failed?
    end

    delegate current_context, current_runner
  end
end
