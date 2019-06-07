class Artifact < ApplicationRecord
	has_one_attached :file

	validate :validate_attrs_that_should_be_a_hash, :validate_attrs_that_should_be_a_array

	['whitelist', 'blacklist'].each do |list_type|
		define_singleton_method :"kinds_#{list_type}" do
			Artifact.where.contains(
				details:  {
					name: 'kinds',
					type: 'list'
				}
			).first.data[list_type]
		end
		
		define_singleton_method :"kinds_#{list_type}_add" do |kind|
			artifact = Artifact.where.contains(
				details:  {
					name: 'kinds',
					type: 'list'
				}
			).first

			if kind.is_a? Array
				artifact.data[list_type] |= kind
			elsif kind.is_a? String
				artifact.data[list_type] |= [kind]
			else
				raise Exception.new "#{kind}:#{kind.class} -> precisa ser uma string ou array"
			end
			
			artifact.save!
		end
	end

  # class << self
	['things', 'activities', 'features'].each do |tag_type|
		['whitelist', 'blacklist'].each do |list_type|
			define_singleton_method :"tags_#{list_type}_#{tag_type}" do
				Artifact.where.contains(
					details:  {
						name: 'tags',
						type: 'list'
					}
				).first.data[list_type][tag_type]
			end
		end
	end

	['things', 'activities', 'features'].each do |tag_type|
		['whitelist', 'blacklist'].each do |list_type|
			define_singleton_method :"tags_#{list_type}_#{tag_type}_add" do |tag|
				artifact = Artifact.where.contains(
					details:  {
						name: 'tags',
						type: 'list'
					}
				).first
				
				if tag.is_a? Array
					artifact.data[list_type][tag_type] |= tag
				elsif tag.is_a? String
					artifact.data[list_type][tag_type] |= [tag]
				else
					raise Exception.new "#{tag}:#{tag.class} -> precisa ser uma string ou array"
				end
				
				artifact.save!
			end
		end
	end
	# end

	private

	def validate_attrs_that_should_be_a_hash
		['details', 'data'].each do |attr|
			unless self.public_send(attr).is_a? Hash
				errors.add(attr, "precisam ser um Hash")
			end
		end
	end

	def validate_attrs_that_should_be_a_array
		if self.details['type'] == 'tags'
			['whitelist', 'blacklist'].each do |list_type|
				['things', 'activities', 'features'].each do |tag_type|
					unless self.data[list_type][tag_type].is_a? Array
						errors.add(:tag_type, "precisam ser um Array")
					end
				end
			end
		elsif self.details['type'] == 'kinds'
			['whitelist', 'blacklist'].each do |list_type|
				unless self.data[list_type].is_a? Array
					errors.add(:tag_type, "precisam ser um Array")
				end
			end
			
		end
	end
end
