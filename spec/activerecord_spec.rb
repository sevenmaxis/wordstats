# encoding: utf-8
require File.dirname(__FILE__) + "/spec_helper"

describe "ActiveRecord" do
  it "should connect to database" do
    class Wordstat < ActiveRecord::Base
      establish_connection :adapter => 'sqlite3', :database => 'test.sqlite3'
      connection.create_table table_name, :force => true do |t|
        t.string :word
        t.string :count
      end
    end
    bob = Wordstat.create!(:word => 'bob', :count => 44)
    Wordstat.all.should have(1).items
    john = Wordstat.create!(:word => 'john', :count => 66)
    Wordstat.all.should have(2).items
    Wordstat.find_by_word('bob').should be
    Wordstat.find_by_word('john').should be
    bob.destroy
    Wordstat.all.should have(1).items
    john.destroy
    Wordstat.all.should have(0).items
  end

  describe "saving data to activerecord" do
    before :all do
      require 'mechanize'
      agent = Mechanize.new
      agent.get('http://kiks.yandex.ru/su/')
      @page = agent.get('http://wordstat.yandex.ru/?cmd=words&page=1&text=seo')
    end

    it "should save first page to database" do
      Wordstat.delete_all
      query = "//table[@class='campaign']/descendant::table[1]//tr[@class='tlist']"
      @page.search(query).each do |r|
        Wordstat.create!( :word => r.elements[0].children.children.text,
                          :count => r.elements[2].children.text)
      end
      Wordstat.all.size.should == 50
      f = Wordstat.first
      f.word.should == 'seo'
      f.count.to_i.should == 103060
      l = Wordstat.last
      l.word.should == 'seo sprint отзывы'
      l.count.to_i.should == 511
    end

    it "should save all pages to database" do

    end
  end
end