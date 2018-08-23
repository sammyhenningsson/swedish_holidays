require 'yaml'
require 'date'
require 'forwardable'

module SwedishHolidays
  DATA_DIR = 'data'.freeze

  class Holiday
    extend Forwardable
    include Comparable

    attr_reader :date, :name

    class << self
      def holiday?(date)
        !find(date).nil?
      end

      def find(date)
        year = date.year
        load(year)
        loaded[year][date.yday]
      end

      def each(year = Date.today.year)
        load(year)
        holidays = loaded[year.to_i].values
        return holidays.each unless block_given?
        holidays.each { |holiday| yield holiday }
      end

      private

      def file(year)
        File.join(DATA_DIR, year.to_s)
      end

      def load(year)
        return unless loaded[year.to_i].empty?
        validate_has_year! year
        holidays = YAML.load_file file(year.to_s)
        holidays.each do |hash|
          holiday = new(hash)
          loaded[year.to_i][holiday.yday] = holiday
        end
      end

      def validate_has_year!(year)
        err_msg = "Sorry I don't have data for year \"#{year}\""
        raise Error, err_msg unless File.exist? file(year)
      end

      def loaded
        @loaded ||= Hash.new { |hash, key| hash[key] = {} }
      end
    end

    def initialize(attr)
      @date = Date.parse(attr[:datum])
      @name = attr[:namn]
    end

    delegate [:wday, :yday] => :date

    def <=>(other)
      date <=> other.date
    end

    def to_s
      "#{date.strftime}: #{name}"
    end
  end
end
