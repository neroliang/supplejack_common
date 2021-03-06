# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

module SupplejackCommon
  # TapuhiGroupEnrichment Class
  class TapuhiGroupsEnrichment < AbstractEnrichment
    def set_attribute_values
      enrich_groups
    end

    def enrich_groups
      if parent_tap = record.parent_tap_id
        parent = find_record(parent_tap)

        if parent
          @record_attributes[parent.id][:category] << "Groups"
          @record_attributes[parent.id][:collection_title] << parent.title

          @record_attributes[parent.id][:deletion_list] << Hash.new {|hash,key| hash[key] = Set.new()}
          @record_attributes[parent.id][:deletion_list].first[:category] << "Other"
        end
      end
    end

    class << self
      def before(source_id)
        RestClient.delete "#{ENV["API_HOST"]}/harvester/fragments/#{source_id.to_s}.json"
      end
    end

    def enrichable?
      !!record
    end
  end
end
