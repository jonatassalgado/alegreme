module MovieDecorators
	module Collections
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods

			def collections
				read_attribute(:collections)
			end

			def collections=(attributes)
				if attributes.is_a? Array
					write_attribute(:collections, attributes)
				elsif attributes.is_a? String
					collections = self.collections.dup
					collections |= [attributes]
					write_attribute(:collections, collections)
				else
					raise Exception, "#{attributes}:#{attributes.class} -> precisa ser uma string ou array"
				end
			end

			class Collection
				attr_accessor :title

				def initialize(title)
					@title = title
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

			def collections_attributes=(attributes)
				if attributes.is_a? Array
					write_attribute(:collections, attributes)
				elsif attributes.is_a? String
					collections = self.collections.dup
					collections |= [attributes]
					write_attribute(:collections, collections)
				else
					raise Exception, "#{attributes}:#{attributes.class} -> precisa ser uma string ou array"
				end
			end

			def build_collections
				values = self.collections.dup
				values << Collection.new('')
				self.collections = values
			end
		end

		module ClassMethods
		end

		private

	end
end
