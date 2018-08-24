require 'swedish_holidays/holiday'
require 'swedish_holidays/utils'

module SwedishHolidays
  extend Enumerable

  class Error < StandardError; end

  def self.[](date, real: true)
    return Holiday.find(Utils.to_date(date), real: real) unless date.is_a? Range
    range = Utils.to_date_range(date)
    each(start: range.first, real: real).take_while { |h| range.include? h.date }
  end

  def self.holiday?(date = nil, real: true)
    Holiday.holiday?(Utils.to_date(date), real: real)
  end

  def self.each(start: nil, real: true)
    enumerator = Utils.enumerator(start, real)
    return enumerator.lazy unless block_given?
    enumerator.each { |holiday| yield holiday }
  end
end
