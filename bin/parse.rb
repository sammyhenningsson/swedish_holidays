#!/usr/bin/env ruby

require 'nokogiri'
require 'yaml'
require 'date'

class Parser
  class Error < StandardError; end

  INPUT_FILES_DIR = File.expand_path('../../tmp_files', __FILE__).freeze
  OUTPUT_FILES_DIR = File.expand_path('../../data', __FILE__).freeze

  WEEKDAYS = {
    0 => 'Söndag',
    1 => 'Måndag',
    2 => 'Tisdag',
    3 => 'Onsdag',
    4 => 'Torsdag',
    5 => 'Fredag',
    6 => 'Lördag'
  }.freeze

  HEADER_TRANSLATIONS = {
    datum: :date,
    namn: :name,
    vecka: :week,
    veckodag: :weekday,
    'dag på året': :yday
  }.freeze

  def initialize(year)
    @year = year
    @headers = []
    @data = []
    validate!
  end

  def validate!
    raise Error, 'Please provide an input file to be parsed' unless @year
    raise Error, "The file \"#{input_file}\" does not exist" unless File.exist? input_file
  end

  def input_file
    @input_file ||= File.join(INPUT_FILES_DIR, @year)
  end

  def parse
    @doc = File.open(input_file) { |f| Nokogiri::XML(f) }
    find_table_rows.each do |tr|
      add_headers find_headers(tr)
      add_data find_data(tr)
    end
    add_eves
    @data.sort_by! { |h| h[:yday].to_i }
  end

  def find_table_rows
    @doc.xpath('//tbody/tr')
  end

  def find_headers(node)
    node.xpath('th')
  end

  def find_data(node)
    node.xpath('td')
  end

  def add_headers(node)
    return unless @headers.empty?
    @headers = node.map do |th|
      HEADER_TRANSLATIONS[th.content.strip.downcase.to_sym]
    end.compact
  end

  def add_data(node)
    return if !node || node.empty?
    raise Error, 'Headers not found' if @headers.empty?
    hash = {}
    node.zip(@headers) do |td, header|
      hash[header] = transform_value(header, td.content.strip)
    end
    @data << hash.merge(real_holiday: true) unless hash.empty?
  end

  def transform_value(key, value)
    return 'Midsommardagen' if value == 'Midsommar'
    return value.to_i if %i[week yday].include? key
    value
  end

  def add_eves
    %w[Påsk Midsommar Jul].each { |name| add_eve(name) }
    add_new_years_eve
  end

  def add_eve(name)
    hash = @data.find { |h| h[:name] == "#{name}dagen" } || return
    date = Date.parse(hash[:date]) - 1
    @data << {
      date: date.strftime,
      name: "#{name}afton",
      week: date.cweek,
      weekday: WEEKDAYS[date.wday],
      yday: date.yday,
      real_holiday: false
    }
  end

  def add_new_years_eve
    hash = @data.first || return
    date = Date.new(Date.parse(hash[:date]).year, 12, 31)
    @data << {
      date: date.strftime,
      name: 'Nyårsafton',
      week: date.cweek,
      weekday: WEEKDAYS[date.wday],
      yday: date.yday,
      real_holiday: false
    }
  end

  def write
    raise Error, 'No data' if @data.empty?
    output_file = File.join(OUTPUT_FILES_DIR, @year)
    Dir.mkdir(OUTPUT_FILES_DIR) unless Dir.exist? OUTPUT_FILES_DIR
    File.open(output_file, 'w') do |file|
      file.write YAML.dump(@data)
    end
  end
end

def parse(year)
  parser = Parser.new(year)
  parser.parse
  parser.write
rescue Parser::Error => e
  puts e.message
  exit 1
end

if File.expand_path($PROGRAM_NAME) == File.expand_path(__FILE__)
  if ARGV[0] == 'all'
    dir_pattern = File.join(Parser::INPUT_FILES_DIR, '*')
    Dir[dir_pattern].each { |file| parse File.basename(file) }
  else
    parse(ARGV[0])
  end
end
