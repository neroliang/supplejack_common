module DnzHarvester
  module Oai
    class Base < DnzHarvester::Base

      self._base_urls[self.identifier] = []
      self._attribute_definitions[self.identifier] = {}

      class_attribute :_enrichment_definitions
      self._enrichment_definitions = {}

      VALID_RECORDS_OPTIONS = [:from, :resumption_token]

      attr_reader :oai_record, :root

      class << self
        attr_reader :response

        def enrich(name, options={})
          self._enrichment_definitions[name] = options || {}
        end

        def client
          @client ||= OAI::Client.new(self.base_urls.first)
        end

        def records(options={})
          options = options.keep_if {|key| VALID_RECORDS_OPTIONS.include?(key) }

          @response = client.list_records(options)
          records = @response.map do |oai_record|
            self.new(oai_record)
          end

          DnzHarvester::Oai::RecordsContainer.new(records)
        end

        def resumption_token
          self.response.try(:resumption_token)
        end
      end

      def initialize(oai_record)
        @oai_record = oai_record
        super
      end

      def deleted?
        self.oai_record.try(:deleted?)
      end

      def set_attribute_values
        @root = oai_record.metadata.try(:first)
        @original_attributes[:identifier] = oai_record.header.identifier

        super
      end

      def attributes
        self.enrich_record
        super
      end

      def attribute_names
        super + self._enrichment_definitions.keys
      end

      def get_value_from(name)
        return nil unless root
        values = root.get_elements(name)
        values = values.map(&:texts).flatten.map(&:to_s) if values.try(:any?)
        values
      end

      def enrichment_document
        @enrichment_document ||= Nokogiri.parse(DnzHarvester::Utils.get(self.enrichment_url))
      end

      def enrich_record
        url = self.enrichment_url
        return nil if url.blank?
        
        self._enrichment_definitions.each do |name, options|
          conditional_option = DnzHarvester::ConditionalOption.new(enrichment_document, options)
          if conditional_option.value.present?
            @original_attributes[name] = conditional_option.value
          end
        end
      end
    end
  end
end
