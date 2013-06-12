module HarvesterCore
  module Sitemap
    class Base < HarvesterCore::Base
    	include HarvesterCore::XmlDocumentMethods

    	self.clear_definitions

    	class_attribute :_record_selector
    	class_attribute :_namespaces

    	class << self
    		def fetch_entries(url=nil)
    			xml_records(url).map(&:entry_url)
    		end

    		def sitemap_entry_selector(xpath)
	    	  self._record_selector = xpath
	    	end

	    	def clear_definitions
	    		super
	    		self._record_selector = nil
	    	end
	    end

		  def initialize(node)
	      @node = node
	      super
	    end

	    def entry_url
	    	@node.text
	    end
    end
  end
end