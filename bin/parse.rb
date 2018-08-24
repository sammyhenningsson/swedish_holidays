#!/usr/bin/env ruby

require 'nokogiri'
require 'yaml'

class Parser
  class Error < StandardError; end

  INPUT_FILES_DIR = File.expand_path('../../tmp_files', __FILE__)
  OUTPUT_FILES_DIR = File.expand_path('../../data', __FILE__)

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
    @headers = node.map { |th| th.content.strip.downcase.to_sym }
  end

  def add_data(node)
    return unless node
    return if node.empty?
    raise Error, 'Headers not found' if @headers.empty?
    hash = {}
    node.zip(@headers) { |td, header| hash[header] = td.content.strip }
    @data << hash unless hash.empty?
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
