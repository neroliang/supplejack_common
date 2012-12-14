module DnzHarvester
  module OptionTransformers
    class StripWhitespaceOption
        
      attr_reader :original_value

      def initialize(original_value)
        @original_value = Array(original_value)
      end

      def value
        original_value.map do |v|
          v.is_a?(String) ? v.strip : v
        end
      end
      
    end
  end
end