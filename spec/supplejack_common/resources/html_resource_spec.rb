# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::HtmlResource do

  let(:klass) { SupplejackCommon::HtmlResource }
  let(:resource) { klass.new("http://google.com/1", {}) }
  
  describe "#document" do
    it "should parse the resource as HTML" do
      resource.stub(:fetch_document) { "</html>" }
      resource.document.should be_a Nokogiri::HTML::Document
    end
  end
end