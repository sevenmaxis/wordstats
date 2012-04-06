# encoding: utf-8
require File.dirname(__FILE__) + "/spec_helper"

describe "Something" do
  it "should retrieve page number" do
    str1 = "http://wordstat.yandex.ru/?cmd=words&page=1&text=test"
    str2 = "http://wordstat.yandex.ru/?cmd=words&page=10&text=test"
    str3 = "http://wordstat.yandex.ru/?cmd=words&page=24&text=test"
    reg = /&page=(\d+)/i
    str1 =~ reg; $1.to_i.should == 1
    str2 =~ reg; $1.to_i.should == 10
    str3 =~ reg; $1.to_i.should == 24
  end

  describe "using mechanize" do
    before :all do
      require 'mechanize'
      agent = Mechanize.new
      agent.get('http://kiks.yandex.ru/su/')
      @page = agent.get('http://wordstat.yandex.ru/?cmd=words&page=1&text=seo')
    end

    it "should find next page on the page" do
      res = @page.link_with(:text=>/следующая/,:href=>/^?cmd=words&page=/)
      res.should be
    end

    it "should go to the next page" do
      res = @page.link_with(:text=>/следующая/,:href=>/^?cmd=words&page=/)
      next_page = res.click
      puts "uri: #{next_page.uri.to_s}"
      next_page.uri.to_s.should =~ /&page=2/
    end

    it "should find the last page" do
      page_number = 1
      next_page = @page
      loop do
        res = next_page.link_with(:text=>/следующая/,:href=>/^?cmd=words&page=/)
        break if res == nil
        page_number += 1
        next_page = res.click
      end
      page_number.should == 24
    end

    it "should find first table" do
      query = "//table[@class='campaign']/descendant::table[1]"
      @page.search(query).size.should == 1
    end

    it "should find elements in first table" do
      query = "//table[@class='campaign']/descendant::table[1]//tr[@class='tlist']"
      @page.search(query).size.should == 50
    end

    it "should retrieve the row of information" do
      query = "//table[@class='campaign']/descendant::table[1]//tr[@class='tlist']"
      res = @page.search(query).first
      res.elements[0].children.children.text.should == "seo"
      res.elements[2].children.text.should == "103060"
    end
  end
end