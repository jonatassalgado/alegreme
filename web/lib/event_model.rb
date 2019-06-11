module EventModel
	module Dates
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def day_of_week(opts = {})
				return if event_ocurrences_is_empty?(self)

				@current_date = ocurrences['dates'].first.to_date
				@difference   = diff_of_days

				case @difference
				when 0
					return add_to_response 'hoje'
				when 1
					return add_to_response 'amanhã'
				when 2..6
					return add_to_response convert_to_literal
				else
					return add_to_response I18n.l(@current_date, format: :short)
				end
			end
		end

		module ClassMethods
			def day_of_week events
				if events.any? {|event| event.is_a? ActiveRecord::Base}
					@datetimes = events.map(&:day_of_week)
				elsif events.is_a? Array
					@datetimes = events.map{|datetime| datetime.transform_keys!(&:to_s)}
				end
				self
			end

			['original', 'formatted'].each do |type|
				define_method :"sort_by_#{type}" do
					@datetimes = @datetimes.sort_by {|day| day[type]}
					self
				end

				define_method :"flat_#{type}" do
					@datetimes = @datetimes.flat_map {|day| day[type]}
					@datetimes
				end
			end

			def values
				@datetimes
			end
		end


		private

		def add_to_response(formatted)
			{
					'original'  => @current_date,
					'formatted' => formatted
			}
		end

		def event_ocurrences_is_empty?(event)
			event.ocurrences['dates'].blank?
		end

		def diff_of_days
			@current_date.mjd - DateTime.now.mjd
		end

		def convert_to_literal
			case @current_date.wday
			when 0
				'domingo'
			when 1
				'segunda'
			when 2
				'terça'
			when 3
				'quarta'
			when 4
				'quinta'
			when 5
				'sexta'
			when 6
				'sábado'
			end
		end
	end
end
