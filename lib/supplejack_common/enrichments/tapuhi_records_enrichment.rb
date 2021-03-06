# The Supplejack Common code is
# Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# See https://github.com/DigitalNZ/supplejack for details.
#
# Supplejack was created by DigitalNZ at the
# National Library of NZ and the Department of Internal Affairs.
# http://digitalnz.org/supplejack

module SupplejackCommon
  # TapuhiRecordsEnrichment Class
  class TapuhiRecordsEnrichment < BaseTapuhiEnrichment

    def set_attribute_values
      denormalise
      build_format
      build_subject
      build_creator
      build_contributor
      relationships
      build_collection_title
      broad_related_authorities
      denormalize_locations
    end

    protected

    def build_format
      recordtype_authorities = attributes[:authorities].find_all { |v| v[:name] == 'recordtype_authority'}
      attributes[:format] += recordtype_authorities.map { |v| v[:text] }
    end

    def build_subject
      subject_authorities = []

      subject_authorities += attributes[:authorities].find_all { |v| v[:name] == 'subject_authority' }
      subject_authorities += attributes[:authorities].find_all { |v| v[:name] == 'name_authority' and v[:role] == '(Subject)' }
      subject_authorities += attributes[:authorities].find_all { |v| v[:name] == 'name_authority' and v[:role] == '(as a related subject)' }
      subject_authorities += attributes[:authorities].find_all { |v| v[:name] == 'place_authority' }
      subject_authorities += attributes[:authorities].find_all { |v| v[:name] == 'iwihapu_authority' }
      
      subjects = subject_authorities.map { |v| v[:text] }

      attributes[:subject] += subjects.map { |v| v.split(" - ") }.flatten
    end

    def denormalize_locations
      locations = []

      place_authorities = record.authorities.find_all { |v| v[:name] == 'place_authority' }

      place_authorities.each do |authority|
        authority = find_record(authority[:authority_id])
        authority.locations.each do |location|
          attributes[:locations] << location.attributes.tap { |l| l.delete("_id") }
        end
      end
    end

    def build_collection_title
      attributes[:collection_title] += attributes[:library_collection]

      # Title is always the first value in the array
      attributes[:collection_title] << attributes[:relation].first
      attributes[:collection_title] << attributes[:is_part_of].first

      attributes[:collection_title] << 'New Zealand Cartoon Archive' if cartoon_archive? and not primary[:collection_title].include? 'New Zealand Cartoon Archive'
    end

    def build_creator
      name_authorities = attributes[:authorities].find_all { |v| v[:name] == 'name_authority' and not ['(Subject)', '(as a related subject)', '(Contributor)'].include?(v[:role]) }
      
      attributes[:creator] += name_authorities.map { |v| v[:text] }
      attributes[:creator] << 'Not specified' if attributes[:creator].empty?
    end

    def build_contributor
      contibutors = attributes[:authorities].find_all { |v| v[:name] == 'name_authority' and v[:role] == '(Contributor)' }
      attributes[:contributor] += contibutors.map { |v| v[:text] }
    end

    def relationships
      parent = find_record(record.parent_tap_id)
      
      intermediates = []

      if parent
        new_parent = parent
        while new_parent = find_record(new_parent.parent_tap_id)
          intermediates << new_parent
        end

        if intermediates.any?
          root = intermediates.pop
        else
          root = parent
        end

        build_authorities(parent, intermediates, root)
        build_relation(root)
        build_is_part_of(parent)

        library_collection = get_library_collection(root.shelf_location)

        attributes[:library_collection] << library_collection if library_collection.present?
      end
    end

    def get_library_collection(shelf_location)
      library_collections = {
        "Arthur Nelson Field Collection" => [
          "MS-Papers-3638", "MS-Group-1534", "MS-Papers-4442-17", 
          "PA1-q-076", "PA1-o-160", "MS-Papers-0212-C/10", 
          "PA11-194", "77-067-2/2", "MS-Papers-6541",
          "PAColl-0450", "ArtEph-1916?-M", "Curios-021-001"
        ],
        "Bible Society in New Zealand Collection" => [
          "MS-Group-1776", "80-179", "87-209",
          "87-204-056/3", "PAColl-8969-1"
        ],
        "Corelli Collection" => [
          "MS-Papers-0606"
        ],
        "Ranfurly Collection" => [
          "PA1-Q-633", "PA1-Q-634", "PA1-f-194", "PA1-f-195", 
          "PAColl-5745-1", "E-567-f ", "E-566-f ", "D-031-001", 
          "D-031-002", "B-139-009", "C-133-005", "C-133-006", 
          "D-022-012", "D-022-013", "MS-Papers-6357", 
          "MSX-4949", "MSX-4950", "MSX-4951", "MSX-4952", 
          "MSY-4600", "MSY-4601", "MSZ-0826", "MSZ-0827",
          "MSZ-0828", "MSZ-0829", "MSZ-0830", "MSZ-0831", 
          "MSZ-0832"
        ],
        "Sir Donald McLean Papers" => [
          "MS-Group-1551"
        ]
      }

      matched_collections = library_collections.select do |collection, shelf_locations| 
        shelf_locations.include? shelf_location
      end

      matched_collections.keys.first
    end

    def broad_related_authorities
      authorities = []
      [:name_authority, :subject_authority, 
       :iwihapu_authority, :place_authority, :recordtype_authority].each do |type|
        authorities += record.authority_taps(type)
      end
      
      authorities.each do |authority_tap|
        authority = find_record(authority_tap)
        if authority.present?
          authority.authorities.each do |a|
            if ['broader_term', 'broad_related_authority'].include?(a.name)
              if a.text.present?
                attributes[:authorities] << {authority_id: a.authority_id, name: 'broad_related_authority', text: a.text}
              end
            end
          end
        end
      end
    end

    private
    
    def build_authorities(parent, intermediates, root)
      attributes[:authorities] << {authority_id: parent.tap_id, name: 'collection_parent', text: parent.title}
      
      intermediates.each do |i|
        attributes[:authorities] << {authority_id: i.tap_id, name: 'collection_mid', text: i.title}
      end

      attributes[:authorities] << {authority_id: root.tap_id, name: 'collection_root', text: root.title}
    end

    def build_relation(parent)
      attributes[:relation] << parent.internal_identifier if record.relation.nil?
      attributes[:relation] << parent.title
      attributes[:relation] << parent.shelf_location
    end

    def build_is_part_of(root)
      attributes[:is_part_of] << root.title
      attributes[:is_part_of] << root.shelf_location
    end

    def cartoon_archive?
      !!attributes[:authorities].find { |v| v[:name] == 'recordtype_authority' and !!v[:text].match(/^(.*[^\w])?cartoons?(.*[^\w])?$/i) }
    end
  end
end
