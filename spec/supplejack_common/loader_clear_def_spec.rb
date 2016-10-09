require "spec_helper"
require "pry"

describe SupplejackCommon::Loader do

  let(:parser_3) { mock(:parser, strategy: "oai", name: "Europeana Parser", content: "class EuropeanaParser < SupplejackCommon::Oai::Base; end", file_name: "europeana.rb") }
  let(:parser_2) { mock(:parser, strategy: "oai", name: "Europeana Parser", content: "class EuropeanaParser < SupplejackCommon::Oai::Base; set 'parser_setset2'; end", file_name: "europeana.rb") }
  let(:parser_1) { mock(:parser, strategy: "oai", name: "Europeana Parser2", content: "class EuropeanaParser2 < SupplejackCommon::Oai::Base; set 'parser_set1'; end", file_name: "europeana.rb") }
  let(:parser) { mock(:parser, strategy: "oai", name: "Europeana Parser", content: "class EuropeanaParser < SupplejackCommon::Oai::Base; setkk 'parser_set'; end", file_name: "europeana.rb") }
  
  let(:loader) { SupplejackCommon::Loader.new(parser, "staging") }
  let(:base_path) { File.dirname(__FILE__) + "/temp" }

  before(:each) do
    SupplejackCommon.parser_base_path = File.dirname(__FILE__) + "/temp"
  end

  after do
    # FileUtils.rmdir(SupplejackCommon.parser_base_path)
  end

  describe "#path" do
    it "builds a absolute path to the temp file" do
      loader.path.should eq "#{base_path}/oai/europeana.rb"
    end

    it "memoizes the path" do
      parser.should_receive(:file_name).once { "/path" }
      3.times { loader.path }
    end
  end

  describe "#parser_class" do
    before(:each) do
      loader.load_parser
    end

    it "returns the class singleton" do
      loader.parser_class.should eq LoadedParser::Staging::EuropeanaParser
    end
  end

  describe "#clear the set parameter every time" do
    it "Parser Class get parser's set" do
      loader.load_parser
      binding.pry
      loader.parser_class.get_set.should eq 'parser_set'
    end

    it "Parser Class get parser_1's set" do
      loader = SupplejackCommon::Loader.new(parser_1, "staging")
      loader.load_parser
      loader.parser_class.get_set.should eq 'parser_set1'
    end

    it "Parser Class get parser_2's set" do
      loader = SupplejackCommon::Loader.new(parser_2, "staging")
      loader.load_parser
      loader.parser_class.get_set.should eq 'parser_setset2'
    end

    it "Parser Class get parser_3's set" do
      loader = SupplejackCommon::Loader.new(parser_3, "staging")
      loader.load_parser
      loader.parser_class.get_set.should be_nil
    end    
  end

  describe "#load_parser" do
    it "creates the tempfile" do
      loader.should_receive(:create_tempfile)
      loader.load_parser
    end

    it "clears the klass definitions" do
      loader.should_receive(:clear_parser_class_definitions)
      loader.load_parser
    end

    it "loads the file" do
      loader.should_receive(:load).with(loader.path)
      loader.load_parser.should be_true

      date = Date.today
      loader.load_parser.new
    end
  end

  describe "loaded?" do
    it "loads the parser file" do
      loader.should_receive(:load_parser)
      loader.loaded?
    end

    it "returns the @loaded value" do
      loader.instance_variable_set("@loaded", true)
      loader.loaded?.should be_true
    end
  end

  describe "clear_parser_class_definitions" do
    before(:each) do
      loader.load_parser
    end

    it "clears the parser class definitions" do
      LoadedParser::Staging::EuropeanaParser.should_receive(:clear_definitions)
      loader.clear_parser_class_definitions
    end
  end
end