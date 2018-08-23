require 'date'
require 'swedish_holidays/holiday'

module SwedishHolidays
  module Utils
    class << self
      def to_date(arg = nil)
        case arg
        when NilClass
          Date.today
        when /\d{4}-\d{2}-\d{2}/
          Date.parse(arg)
        when Date
          arg
        else
          raise Error, "Don't know how to convert #{arg} (#{arg.class}) to Date"
        end
      end

      def to_date_range(range)
        if range.exclude_end?
          to_date(range.first)...to_date(range.last)
        else
          to_date(range.first)..to_date(range.last)
        end
      end

      def enumerator(start = nil)
        start_date = to_date(start)
        Enumerator.new { |yielder| iterate(yielder, start_date) }
      end

      private

      def iterate(yielder, start_date)
        year = start_date.year
        loop do
          Holiday.each(year) do |holiday|
            next if holiday.date < start_date
            yielder << holiday
          end
          year += 1
        end
      rescue Error
      end
    end
  end
end
