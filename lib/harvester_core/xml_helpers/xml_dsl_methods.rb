module HarvesterCore
  module XmlDslMethods
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_namespaces
    end

    def fetch(xpath, namespaces=[])
      xpath = xpath[:xpath] if xpath.is_a?(Hash)
      values = HarvesterCore::XpathOption.new(self.document, {xpath: xpath, namespaces: namespaces}, self.class._namespaces).value
      HarvesterCore::AttributeValue.new(values)
    end

    def node(xpath, name_spaces_hash={})
      if self.document
        name_spaces = name_spaces_hash.is_a?(Hash) ? name_spaces_hash : nil
        self.document.xpath(xpath, name_spaces)
      else
        HarvesterCore::AttributeValue.new(nil)
      end
    end

    def strategy_value(options={})
      HarvesterCore::XpathOption.new(self.document, options, self.class._namespaces).value if options[:xpath]
    end

    module ClassMethods
      def namespaces(namespaces={})
        self._namespaces ||= {}
        self._namespaces.merge!(namespaces)
      end
    end
  end
end