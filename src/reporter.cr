module Spec2
  abstract class Reporter
    abstract def configure_output(output)
    abstract def context_started(context)
    abstract def context_finished(context)
    abstract def example_started(example)
    abstract def example_succeeded(example)
    abstract def example_failed(example, exception)
    abstract def example_errored(example, exception)
    abstract def report

    private def elapsed_time
      elapsed_time = Time.now - Spec2.started_at
      total_seconds = elapsed_time.total_seconds

      if total_seconds < 1
        output.puts "Finished in #{elapsed_time.total_milliseconds.round(2)} milliseconds"
      elsif total_seconds < 60
        output.puts "Finished in #{total_seconds.round(2)} seconds"
      else
        minutes = elapsed_time.minutes
        seconds = elapsed_time.seconds
        output.puts "Finished in #{minutes}:#{seconds < 10 ? "0" : ""}#{seconds} minutes"
      end
    end
  end
end
