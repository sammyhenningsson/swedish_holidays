require 'date'
require 'swedish_holidays/holiday'

module SwedishHolidays
  module Utils
    VALUE_NOT_GIVEN = Object.new

    class << self
      def to_date(arg = nil)
        case arg
        when NilClass
          Date.today
        when /\d{4}\Z/
          Date.parse("#{date}-01-01")
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

      def enumerator(start, include_informal)
        start_date = to_date(start)
        Enumerator.new { |yielder| iterate(yielder, start_date, include_informal) }
      end

      def include_informal?(real, include_informal)
        warn <<~DEPRECATION if real != VALUE_NOT_GIVEN
          warn 'Keyword `:real` is deprecated!
          Use `:include_informal` instead (Note: that the value is inverted)'
        DEPRECATION

        if include_informal != VALUE_NOT_GIVEN
          include_informal
        elsif real != VALUE_NOT_GIVEN
          !real
        else
          false
        end
      end

      private

      def iterate(yielder, start_date, include_informal)
        year = start_date.year
        loop do
          Holiday.each(year, include_informal: include_informal) do |holiday|
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
