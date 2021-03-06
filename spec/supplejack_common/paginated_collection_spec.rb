# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::PaginatedCollection do
  
  let(:klass) { SupplejackCommon::PaginatedCollection }
  let(:collection) { klass.new(SupplejackCommon::Base, {page_parameter: "page", type: "item", per_page_parameter: "per_page", per_page: 5, page: 1}, {limit: 1}) }

  
  describe "#initialize" do
    it "assigns the klass" do
      collection.klass.should eq SupplejackCommon::Base
    end

    it "initializes pagination options" do
      collection.page_parameter.should eq "page"
      collection.per_page_parameter.should eq "per_page"
      collection.per_page.should eq 5
      collection.page.should eq 1
    end

    it "initializes a counter and extra options" do
      collection.counter.should eq 0
      collection.options.should eq(limit: 1)
    end
  end

  describe "#each" do
    before do 
      collection.klass.stub(:base_urls) { ["http://go.gle/", "http://dnz.harvest/1"]}
      collection.stub(:yield_from_records) { true }
      collection.stub(:paginated?) { false }
    end

    it "should process all base_urls" do
      SupplejackCommon::Base.should_receive(:fetch_records).with("http://go.gle/")
      SupplejackCommon::Base.should_receive(:fetch_records).with("http://dnz.harvest/1")
      collection.each do; end
    end

    context "paginated" do

      before do 
        collection.stub(:paginated?) { true }
        collection.stub(:url_options) { {page: 1, per_page: 10} }
        collection.klass.stub(:base_urls) { ["http://go.gle/", "http://dnz.harvest/1"]}
        SupplejackCommon::Base.stub(:_total_results) { 1 }
      end

      it "should call fetch records with a paginated url" do
        SupplejackCommon::Base.should_receive(:fetch_records).with("http://go.gle/?page=1&per_page=10")
        SupplejackCommon::Base.should_receive(:fetch_records).with("http://dnz.harvest/1?page=1&per_page=10")
        collection.each do; end
      end
    end
  end

  describe "#paginated?" do
    it "returns true when page and per_page are set" do
      collection.send(:paginated?).should be_true
    end

    it "returns false when no pagination options are set" do
      collection = klass.new(SupplejackCommon::Base, nil, {})
      collection.send(:paginated?).should be_false
    end
  end

  describe "#next_url" do
    context "paginated" do

      before do 
        collection.stub(:paginated?) { true }
        collection.stub(:url_options) { {page: 1, per_page: 10} }
      end
      
      it "returns the url with paginated options" do
        collection.send(:next_url, "http://go.gle/").should eq "http://go.gle/?page=1&per_page=10"
      end

      it "appends to existing url parameters" do
        collection.send(:next_url, "http://go.gle/?sort=asc").should eq "http://go.gle/?sort=asc&page=1&per_page=10"
      end
    end

    context "not paginated" do

      before { collection.stub(:paginated?) }

      it "returns the url passed" do
        collection.send(:next_url, "http://goog.gle").should eq "http://goog.gle"
      end
    end
  end

  describe "#url_options" do
    it "returns a hash with the url options" do
      collection.send(:url_options).should eq({"page" => 1, "per_page" => 5})
    end
  end

  describe "#current_page" do
    context "page type pagination" do
      let(:collection) { klass.new(SupplejackCommon::Base, {page_parameter: "page", type: "page", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "returns the current_page" do
        collection.send(:current_page).should eq 1
      end
    end

    context "item type pagination" do
      let(:collection) { klass.new(SupplejackCommon::Base, {page_parameter: "page", type: "item", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "returns the first page" do
        collection.send(:current_page).should eq 1
      end

      it "returns the second page" do
        collection.stub(:page) { 6 }
        collection.send(:current_page).should eq 2
      end

      it "returns the third page" do
        collection.stub(:page) { 11 }
        collection.send(:current_page).should eq 3
      end
    end
  end

  describe "#total_pages" do
    it "returns the total number of pages" do
      collection.stub(:total) { 36 }
      collection.stub(:per_page) { 10 }
      collection.send(:total_pages).should eq 4
    end
  end

  describe "increment_page_counter!" do
    context "page type pagination" do
      let(:collection) { klass.new(SupplejackCommon::Base, {page_parameter: "page", type: "page", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "increments the page by one" do
        collection.send(:increment_page_counter!)
        collection.page.should eq 2
      end
    end

    context "item type pagination" do
      let(:collection) { klass.new(SupplejackCommon::Base, {page_parameter: "page", type: "item", per_page_parameter: "per_page", per_page: 5, page: 1}) }

      it "increments the page by the number per_page" do
        collection.send(:increment_page_counter!)
        collection.page.should eq 6
      end
    end
  end
end