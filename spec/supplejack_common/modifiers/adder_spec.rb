# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon::Modifiers::Adder do

  let(:klass) { SupplejackCommon::Modifiers::Adder }
  let(:original_value) { ["Images"] }
  let(:replacer) { klass.new(original_value, "Videos") }

  describe "modify" do
    it "adds a value to the original value" do
      replacer.modify.should eq ["Images", "Videos"]
    end

    it "adds an array of values to the original_value" do
      replacer.stub(:new_value) { ["Videos", "Audio"] }
      replacer.modify.should eq ["Images", "Videos", "Audio"]
    end
  end
end