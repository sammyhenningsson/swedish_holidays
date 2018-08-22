module SwedishHolidays
  DATA_DIR = 'data'.freeze

  class Error < StandardError; end

  class Year
    class << self
      def find(year)
        load(year) unless loaded[year.to_i]
        loaded[year.to_i]
      end

      def load(year)
        err_msg = "Sorry I don't have data for year \"#{year}\""
        raise Error, err_msg unless File.exist? file(year)
        loaded[year.to_i] = YAML.load_file file(year)
      end

      def loaded
        @loaded ||= {}
      end

      def years_with_data
        Dir[File.join(DATA_DIR, '*')].tap { |dirs| puts "dirs: #{dirs}" }
      end

      private

      def file(year)
        File.join(DATA_DIR, year)
      end
    end
  end
end
