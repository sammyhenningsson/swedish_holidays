require 'swedish_holidays/holiday'
require 'swedish_holidays/utils'

module SwedishHolidays
  extend Enumerable

  class Error < StandardError; end

  class << self
    def [](date, real: no_arg, include_informal: no_arg)
      informal = Utils.include_informal?(real, include_informal)
      return Holiday.find(Utils.to_date(date), include_informal: informal) unless date.is_a? Range

      range = Utils.to_date_range(date)
      each(start: range.first, include_informal: informal).take_while { |h| range.include? h.date }
    end

    def holiday?(date = nil, real: no_arg, include_informal: no_arg)
      informal = Utils.include_informal?(real, include_informal)
      date = Utils.to_date(date)
      Holiday.holiday?(date, include_informal: informal)
    end

    def each(start: nil, real: no_arg, include_informal: no_arg, &block)
      informal = Utils.include_informal?(real, include_informal)
      enumerator = Utils.enumerator(start, informal)
      return enumerator.lazy unless block_given?

      enumerator.each(&block)
    end

    private

    def no_arg
      Utils::VALUE_NOT_GIVEN
    end
  end
end
