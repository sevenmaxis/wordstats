# encoding: utf-8
$:.unshift(File.dirname(__FILE__))
require 'wordstats/version'
require 'mechanize'
require File.join(File.dirname(__FILE__), 'config/environment.rb')

module Wordstats

  class Wordstat < ActiveRecord::Base
    establish_connection :adapter => 'sqlite3', :database => 'wordstats.sqlite3'
    connection.create_table table_name, :force => true do |t|
      t.string :word
      t.string :count
    end
  end

  class Console
    def initialize
      run
    end

    def run
      puts "=== Wordstats application ==="
      puts "Please enter the keyword"
      print "_ "
      STDOUT.flush
      word = gets.chomp
      puts "The keyword is processed"
      runner = Runner.new(word)
      puts "The keyword has been processed"
      runner.print_wordstats
      print_messages
      until (input = gets.chomp) == 'exit' do
        case input
          when 'next'
            runner.next
            runner.print_wordstats
            print_messages
          when 'prev'
            runner.prev
            runner.print_wordstats
            print_messages
          else
            puts "You've made a mistake, try again"
            print_messages
        end
      end
      puts "Have a nice day, bye"
    end

    def print_messages
      puts "To print next page type 'next'"
      puts "To print previous page type 'prev'"
      puts "To exit the application type 'exit'"
      print "_ "
    end

  end

  class Runner
    RECORDS_PER_PAGE = 30

    def initialize(word)
      @word = word
      execute
    end

    def execute
      init_page
      Wordstat.delete_all
      begin
        get_records.each do |record|
          Wordstat.create!(
              :word => record.elements[0].children.children.text,
              :count => record.elements[2].children.text)
        end
      end while next_page
      @max_page = (Wordstat.all.size + RECORDS_PER_PAGE - 1) / RECORDS_PER_PAGE
    end

    def next
      @current_page += 1 if @current_page < @max_page
    end

    def prev
      @current_page -= 1 if @current_page > 1
    end

    def print_wordstats
      str = "|__________________________________________________|__________|"
      @current_page ||= 1
      puts ""
      puts ""
      puts "++++++++++ Page #{@current_page} +++++++++++++++++++++++++++++++++++++++++++++"
      puts "| words                                            |   counts |"
      puts str
      start_index = (@current_page - 1) * RECORDS_PER_PAGE
      Wordstat.limit(RECORDS_PER_PAGE).offset(start_index).each do |record|
        puts sprintf("| %-49s|%9d |", record.word, record.count)
      end
      puts str
    end

    private

    def init_page
      agent = Mechanize.new
      agent.get('http://kiks.yandex.ru/su/')
      query = 'http://wordstat.yandex.ru/?cmd=words&page=1&text='
      @page = agent.get(query + @word)
    end

    def next_page
      result = @page.link_with(:text=>/следующая/,:href=>/^?cmd=words&page=/)
      result == nil ? false : (@page = result.click; true)
    end

    def get_records
      query = "//table[@class='campaign']/descendant::table[1]//tr[@class='tlist']"
      @page.search(query)
    end
  end
end


