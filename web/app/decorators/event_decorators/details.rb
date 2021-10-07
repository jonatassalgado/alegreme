module EventDecorators
	module Details
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods

			# def details_description
			# 	details['description']
			# end
			#
			# def details_description=(value)
			# 	details['description'] = value
			# end

			def prices
				read_attribute(:prices)&.map(&:to_i)
			end
			
			def prices_min
				read_attribute(:prices)&.map(&:to_i).try(:min)
			end
			#
			# def details_prices=(value)
			# 	if value.is_a? Array
			# 		details['prices'] = value
			# 	elsif value.is_a? String
			# 		details['prices'] |= [value]
			# 	else
			# 		raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
			# 	end
			# end
			#
			# def details_ticket_url
			# 	details['ticket_url']
			# end
			#
			# def details_ticket_url=(value)
			# 	details['ticket_url'] = value
			# end
			#
			# def details_source_url
			# 	details['source_url']
			# end
			#
			# def details_source_url=(value)
			# 	details['source_url'] = value
			# end
			#
			# def place_details_name
			# 	place&.details&.dig('name').try(:titleize)
			# end
			#
			# def place_details_name=(value)
			# 	place&.details['name'] = value
			# end
		end

		module ClassMethods

		end


		private



	end
end
