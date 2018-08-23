require 'swedish_holidays/holiday'
require 'swedish_holidays/utils'

module SwedishHolidays
  extend Enumerable

  class Error < StandardError; end

  def self.[](date)
    return Holiday.find Utils.to_date(date) unless date.is_a? Range
    range = Utils.to_date_range(date)
    each(start: range.first).take_while { |h| range.include? h.date }
  end

  def self.holiday?(date = nil)
    Holiday.holiday? Utils.to_date(date)
  end

  def self.each(start: nil)
    enumerator = Utils.enumerator(start)
    return enumerator.lazy unless block_given?
    enumerator.each { |holiday| yield holiday }
  end
end
