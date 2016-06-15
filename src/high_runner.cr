module Spec2
  class HighRunner
    @current_runner : Runner?

    getter reporter, runner, order, output, root, exit_code
    getter! current_runner
    def initialize(@root : Context)
      @exit_code = 0
    end

    def contexts
      [root]
    end

    def configure_reporter(@reporter : Reporter::Factory)
    end

    def configure_runner(@runner : Runner::Factory)
    end

    def configure_order(@order : Order::Factory)
    end

    def configure_output(@output : Output::Factory)
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

      output_class = self.output
      unless output_class
        raise OutputIsNotConfigured.new(
          "Please configure output with Spec2.configure_output(output)",
        )
      end

      reporter = reporter_class.build
      @current_runner = runner_class.build
      order = order_class.build
      output = output_class.build

      reporter.configure_output(output)

      current_runner.run_context(reporter, order, root)
      reporter.report

      want_exit(1) if current_runner.failed?
    end

    delegate current_context, to: current_runner
  end
end
