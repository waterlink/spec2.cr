require "./spec_helper"
require "../src/elapsed_time"

module Spec2
  Spec2.describe ElapsedTime do
    let(started_at) { Time.new(2014, 4, 21, 13, 27, 33, 57) }

    describe "#to_s" do
      context "when seconds < 1" do
        it "returns in milliseconds" do
          expect(ElapsedTime.new(
            started_at, started_at + 1.milliseconds,
          ).to_s).to eq("1.0 milliseconds")

          expect(ElapsedTime.new(
            started_at, started_at + 50.milliseconds,
          ).to_s).to eq("50.0 milliseconds")

          expect(ElapsedTime.new(
            started_at, started_at + 999.milliseconds,
          ).to_s).to eq("999.0 milliseconds")
        end

        it "returns in milliseconds rounded to .2" do
          expect(ElapsedTime.new(
            started_at,
            started_at + Time::Span.new(36 * 10000)
          ).to_s).to eq("36.0 milliseconds")

          expect(ElapsedTime.new(
            started_at,
            started_at + Time::Span.new(36.5 * 10000)
          ).to_s).to eq("36.5 milliseconds")

          expect(ElapsedTime.new(
            started_at,
            started_at + Time::Span.new(36.57 * 10000)
          ).to_s).to eq("36.57 milliseconds")

          expect(ElapsedTime.new(
            started_at,
            started_at + Time::Span.new(36.573 * 10000)
          ).to_s).to eq("36.57 milliseconds")
        end
      end

      context "when 1 <= total seconds < 60" do
        it "returns in seconds" do
          expect(ElapsedTime.new(
            started_at, started_at + 1.seconds,
          ).to_s).to eq("1.0 seconds")

          expect(ElapsedTime.new(
            started_at, started_at + 34.seconds,
          ).to_s).to eq("34.0 seconds")

          expect(ElapsedTime.new(
            started_at, started_at + 59.seconds,
          ).to_s).to eq("59.0 seconds")

          expect(ElapsedTime.new(
            started_at, started_at + 60.seconds,
          ).to_s).not_to eq("60 seconds")
        end

        it "returns in seconds rounded to .2" do
          expect(ElapsedTime.new(
            started_at, started_at + 7.seconds,
          ).to_s).to eq("7.0 seconds")

          expect(ElapsedTime.new(
            started_at, started_at + 7.3.seconds,
          ).to_s).to eq("7.3 seconds")

          expect(ElapsedTime.new(
            started_at, started_at + 7.34.seconds,
          ).to_s).to eq("7.34 seconds")

          expect(ElapsedTime.new(
            started_at, started_at + 7.348.seconds,
          ).to_s).to eq("7.35 seconds")
        end
      end

      context "when 1 minute <= elapsed < 1 hour" do
        it "returns minutes:seconds" do
          expect(ElapsedTime.new(
            started_at, started_at + 60.seconds,
          ).to_s).to eq("1:00 minutes")

          expect(ElapsedTime.new(
            started_at, started_at + 1.3.minutes,
          ).to_s).to eq("1:18 minutes")

          expect(ElapsedTime.new(
            started_at, started_at + 25.7.minutes,
          ).to_s).to eq("25:42 minutes")

          expect(ElapsedTime.new(
            started_at, started_at + 59.99.minutes,
          ).to_s).to eq("59:59 minutes")
        end

        it "formats seconds part as 2 digit 0-padded" do
          expect(ElapsedTime.new(
            started_at, started_at + 1.1.minutes,
          ).to_s).to eq("1:06 minutes")

          expect(ElapsedTime.new(
            started_at, started_at + 69.seconds,
          ).to_s).to eq("1:09 minutes")

          expect(ElapsedTime.new(
            started_at, started_at + 70.seconds,
          ).to_s).to eq("1:10 minutes")
        end
      end

      context "when total_seconds >= 1 hour" do
        it "returns in hours" do
          expect(ElapsedTime.new(
            started_at, started_at + 60.minutes,
          ).to_s).to eq("1:00:00 hours")

          expect(ElapsedTime.new(
            started_at, started_at + 7.37.hours,
          ).to_s).to eq("7:22:12 hours")

          expect(ElapsedTime.new(
            started_at, started_at + 7832.26.hours,
          ).to_s).to eq("7832:15:36 hours")
        end

        it "formats seconds part as 2-digits 0-padded" do
          expect(ElapsedTime.new(
            started_at, started_at + 60.1.minutes,
          ).to_s).to eq("1:00:06 hours")
        end

        it "formats minutes part as 2-digits 0-padded" do
          expect(ElapsedTime.new(
            started_at, started_at + 61.minutes,
          ).to_s).to eq("1:01:00 hours")
        end
      end
    end
  end
end
