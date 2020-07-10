module EventDecorators
	module Ocurrences
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def day_of_week(opts = {})
				return if event_ocurrences_is_empty?(self)

				@today        = Date.current
				@current_date = ocurrences['dates'].first.to_date
				@difference   = diff_of_days

				case @difference
				when 0
					return add_to_response 'hoje', order: 1
				when 1
					return add_to_response 'amanhã', order: 2
				when 2..6
					return add_to_response convert_to_literal, order: @difference
				when 7..14
					if opts[:active_range]
						return add_to_response('próxima semana', range: true, order: 7)
					else
						return add_to_response("#{I18n.l(@current_date, format: :week)} · #{I18n.l(@current_date, format: :short)}", order: 8)
					end
				when 15..90
					if opts[:active_range]
						return add_to_response('próximos 90 dias', range: true, order: 15)
					else
						return add_to_response("#{I18n.l(@current_date, format: :short)} · #{I18n.l(@current_date, format: :week)}", order: 15)
					end
				else
					if opts[:active_range]
						nil
					else
						return add_to_response I18n.l(@current_date, format: :short)
					end
				end
			end
		end

		module ClassMethods
			def day_of_week(events, opts = {})
				if events.any? { |event| event.is_a? ActiveRecord::Base }
					@datetimes = events.map { |event| event.day_of_week(opts) }.compact
				elsif events.is_a? Array
					@datetimes = events.map { |datetime| datetime.transform_keys!(&:to_s) }.compact
				else
					@datetimes = []
				end
				self
			end

			['date', 'decorator', 'order'].each do |type|
				define_method :"sort_by_#{type}" do
					@datetimes = @datetimes.sort_by { |day| day[type] }
					self
				end

				define_method :"flat_#{type}" do
					@datetimes = @datetimes.map { |day| day[type] }
					self
				end
			end

			def uniq
				@datetimes = @datetimes.uniq
				self
			end

			def compact_range
				ranges         = {}
				name_to_insert = {}
				response       = []


				@datetimes.each { |days_obj|

					if days_obj && days_obj['is_range']
						decorator         = days_obj['decorator']
						ranges[decorator] ||= []
						ranges[decorator] << days_obj

						name_to_insert[decorator] ||= decorator
					else
						response.append(days_obj)
					end
				}

				name_to_insert.keys.each do |decorator|
					to = {
							'date'      => ranges[decorator].map { |a| a['date'] }.minmax,
							'string'    => ranges[decorator].map { |a| a['string'] }.minmax,
							'decorator' => name_to_insert[decorator],
							'range'     => name_to_insert[decorator],
							'is_range'  => true
					}


					response.append(to)
				end
				@datetimes = response
				self
			end

			def values
				@datetimes
			end
		end


		private

		def add_to_response(decorator, opts = {})
			{
					'date'      => @current_date,
					'string'    => @current_date.to_s,
					'decorator' => decorator,
					'is_range'  => opts[:range] ? true : false,
					'order'     => opts[:order]
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
