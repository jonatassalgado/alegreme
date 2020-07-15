module MovieDecorators
	module Streamings
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def details_title
				details['title']
			end

			def details_title=(value)
				details['title'] = value
			end

			def details_cover
				details['cover']
			end

			def details_cover=(value)
				details['cover'] = value
			end

			def details_description
				details['description']
			end

			def details_description=(value)
				details['description'] = value
			end

			def details_trailler
				details['trailler']
			end

			def details_trailler=(value)
				details['trailler'] = value
			end

			def details_genres
				details['genres']
			end

			def details_genres=(values)
				details['genres'] |= [values]
			end

			def details_original_title
				details['original_title']
			end

			def details_original_title=(value)
				details['original_title'] = value
			end

			def details_popularity
				details['popularity']
			end

			def details_popularity=(value)
				details['popularity'] = value
			end

			def details_vote_average
				details['vote_average']
			end

			def details_vote_average=(value)
				details['vote_average'] = value
			end

			def details_adult
				details['adult']
			end

			def details_adult=(value)
				details['adult'] = value
			end

			def details_tmdb_id
				details['tmdb_id']
			end

			def details_tmdb_id=(value)
				details['tmdb_id'] = value
			end

			def streamings
				read_attribute(:streamings).map { |values| Streaming.new(values) }
			end

			def streamings=(attributes)
				if attributes.is_a? Array
					write_attribute(:streamings, attributes)
				elsif attributes.is_a? String
					streamings = self.streamings.dup
					streamings |= [attributes]
					write_attribute(:streamings, streamings)
				else
					raise Exception, "#{attributes}:#{attributes.class} -> precisa ser uma string ou array"
				end
			end

			class Streaming
				attr_accessor :display_name, :url

				def initialize(hash)
					@display_name = hash['display_name']
					@url          = hash['url']
				end

				def persisted?()
					false
				end

				def new_record?()
					false
				end

				def marked_for_destruction?()
					false
				end

				def _destroy()
					false
				end
			end

			def streamings_attributes=(attributes)
				if attributes.is_a? Array
					write_attribute(:streamings, attributes)
				elsif attributes.is_a? String
					streamings = self.streamings.dup
					streamings |= [attributes]
					write_attribute(:streamings, streamings)
				elsif attributes.is_a? Hash
					streamings = []
					attributes.each do |index, attrs|
						next if attrs["_destroy"]
						streamings << attrs
					end
					write_attribute(:streamings, streamings)
				else
					raise Exception, "#{attributes}:#{attributes.class} -> precisa ser uma string, array ou hash"
				end
			end

			def build_streamings
				values = self.streamings.dup
				values << Streaming.new({display_name: '',
				                         url:          ''})
				self.streamings = values
			end
		end

		module ClassMethods
		end

		private

	end
end
