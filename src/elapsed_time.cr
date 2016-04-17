module Spec2
  class ElapsedTime
    FORMATTERS = {
      # seconds range => formatter class
      (0...1) => InMilliseconds,
      (1...60) => InSeconds,
      (60...3600) => InMinutes,
      (3600..Float64::INFINITY) => InHours,
    }

    @started_at : Time
    @time_now : Time

    @_total_seconds : Float64?

    private getter time_now, started_at
    def initialize
      initialize(Spec2.started_at, Time.now)
    end

    def initialize(@started_at, @time_now)
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

    record Format2DigitNumber, value : Int32 do
      def to_s
        "%02d" % value
      end

      macro delegate(name, target)
        def {{name.id}}
          Format2DigitNumber.new({{target.id}}.{{name.id}}).to_s
        end
      end
    end

    record InSeconds, elapsed : Time::Span do
      def to_s
        "#{elapsed.total_seconds.round(2)} seconds"
      end
    end

    record InMilliseconds, elapsed : Time::Span do
      def to_s
        "#{elapsed.total_milliseconds.round(2)} milliseconds"
      end
    end

    record InMinutes, elapsed : Time::Span do
      def to_s
        "#{elapsed.minutes}:#{seconds} minutes"
      end

      Format2DigitNumber.delegate seconds, elapsed
    end

    record InHours, elapsed : Time::Span do
      def to_s
        "#{hours}:#{minutes}:#{seconds} hours"
      end

      private def hours
        elapsed.total_hours.to_i
      end

      Format2DigitNumber.delegate minutes, elapsed
      Format2DigitNumber.delegate seconds, elapsed
    end
  end
end
