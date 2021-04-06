require 'yaml'
require 'date'
require 'forwardable'

module SwedishHolidays
  DATA_DIR = File.expand_path('../../../data', __FILE__).freeze

  class Holiday
    extend Forwardable
    include Comparable

    attr_reader :date, :name

    class << self
      def holiday?(date, real: no_arg, include_informal: no_arg)
        informal = Utils.include_informal?(real, include_informal)
        !find(date, include_informal: informal).nil?
      end

      def find(date, real: no_arg, include_informal: no_arg)
        informal = Utils.include_informal?(real, include_informal)
        year = date.year
        load(year)
        holiday = loaded[year][date.yday]
        return holiday if informal
        return holiday if holiday&.real?
      end

      def each(year = Date.today.year, real: no_arg, include_informal: no_arg, &block)
        informal = Utils.include_informal?(real, include_informal)
        load(year)
        holidays = loaded[year.to_i].values
        holidays.delete_if { |holiday| !informal && holiday.informal? }
        return holidays.each(&block) if block

        holidays.each
      end

      private

      def no_arg
        Utils::VALUE_NOT_GIVEN
      end

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
      @date = Date.parse(attr[:date])
      @name = attr[:name]
      @informal = attr.fetch(:informal_holiday) { !attr[:real_holiday] }
    end

    delegate [:wday, :yday] => :date

    def <=>(other)
      date <=> other.date
    end

    def to_s
      "#{date.strftime}: #{name}"
    end

    def real?
      !informal?
    end

    def informal?
      @informal
    end
  end
end
