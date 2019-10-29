module UserDecorators
	module Notifications

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def notifications_devices
				notifications.dig('devices') || []
			end

			def notifications_devices=(value)
				if notifications['devices'].size >= 3
					notifications['devices'].delete_at(0)
				end

				if value.is_a? Array
					notifications['devices'] = value
				elsif value.is_a? String
					notifications['devices'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end

			def notifications_topics
				notifications.dig('topics') || {}
			end

			def notifications_topics=(value)
				notifications['topics'].deep_merge! value
			end

			def notifications_topics_all_active
				notifications.dig('topics', 'all', 'active')
			end

		end

		module ClassMethods
		end


		private
	end
end