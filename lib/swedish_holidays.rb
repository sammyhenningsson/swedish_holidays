require 'swedish_holidays/year'

module SwedishHolidays
  def self.[](year)
    Year.find(year)
  end
end
