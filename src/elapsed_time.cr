module Spec2
  class ElapsedTime
    FORMATTERS = {
      # seconds range => formatter class
      (0...1) => InMilliseconds,
      (1...60) => InSeconds,
      (60...3600) => InMinutes,
      (3600..Float32::INFINITY) => InHours,
    }

    private getter time_now, started_at
    def initialize(@started_at = Spec2.started_at, @time_now = Time.now)
    end

    def to_s
      formatter_class.new(elapsed).to_s
    end

    private def formatter_class
      FORMATTERS
        .to_a
        .find(&.first.includes?(total_seconds))
        .not_nil!
        .last
    end

    private def elapsed
      time_now - started_at
    end

    private def total_seconds
      @_total_seconds ||= elapsed.total_seconds
    end

    record Format2DigitNumber, value do
      def to_s
        "%02d" % value
      end
    end

    record InSeconds, elapsed do
      def to_s
        "#{elapsed.total_seconds.round(2)} seconds"
      end
    end

    record InMilliseconds, elapsed do
      def to_s
        "#{elapsed.total_milliseconds.round(2)} milliseconds"
      end
    end

    record InMinutes, elapsed do
      def to_s
        "#{elapsed.minutes}:#{seconds} minutes"
      end

      private def seconds
        Format2DigitNumber.new(elapsed.seconds).to_s
      end
    end

    record InHours, elapsed do
      def to_s
        "#{hours}:#{minutes}:#{seconds} hours"
      end

      private def hours
        elapsed.total_hours.to_i
      end

      private def minutes
        Format2DigitNumber.new(elapsed.minutes).to_s
      end

      private def seconds
        Format2DigitNumber.new(elapsed.seconds).to_s
      end
    end
  end
end
