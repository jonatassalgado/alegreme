class CalendarComponent < ViewComponent::Base

	attr_accessor :view_context, :options

	def initialize(events:, start_date:, user:, indicators:, filter: false)
		@start_date = start_date
		@events     = events
		@indicators = indicators || events&.map(&:start_time)
		@user       = user
		@filter     = filter

		@params  = {}
		@options = {}

		@params.merge!(@options.fetch(:params, {}))
	end

	def td_classes_for(day)
		today = Date.current

		td_class = ['day h-12 text-center px-1 rounded-full cursor-pointer md:hover:bg-green-100 md:hover:text-green-500']
		td_class << "wday-#{day.wday.to_s}"
		td_class << 'bg-gray-100 rounded-full text-gray-600' if today == day
		td_class << 'text-gray-300' if today > day
		td_class << '' if today < day
		td_class << 'filter bg-green-500 text-white rounded-full text-white font-semibold' if day.to_date == start_date.to_date && @filter
		td_class << 'text-gray-300' if start_date.month != day.month && day < start_date
		td_class << 'text-gray-300' if start_date.month != day.month && day > start_date # next month
		td_class << '' if start_date.month == day.month # current month
		td_class << 'has-events' if sorted_events&.fetch(day, []).any?

		td_class
	end

	def tr_classes_for(week)
		today    = Date.current
		tr_class = ['week']
		tr_class << 'current-week' if week.include?(today)

		tr_class
	end

	def date_range
		(start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week).to_a
	end

	private

	def partial_name
		@options[:partial] || self.class.name.underscore
	end

	def attribute
		options.fetch(:attribute, :start_time).to_sym
	end

	def end_attribute
		options.fetch(:end_attribute, :end_time).to_sym
	end

	def start_date_param
		options.fetch(:start_date_param, :start_date).to_sym
	end

	def sorted_events
		begin
			events = @events.reject { |e| e.send(attribute).nil? }.sort_by(&attribute)
			group_events_by_date(events)
		rescue
			{}
		end
	end

	def group_events_by_date(events)
		events_grouped_by_date = {}

		events.each do |event|
			event_start_date = event.send(attribute).to_date
			event_end_date   = (event.respond_to?(end_attribute) && !event.send(end_attribute).nil?) ? event.send(end_attribute).to_date : event_start_date
			(event_start_date..event_end_date.to_date).each do |enumerated_date|
				events_grouped_by_date[enumerated_date] = [] unless events_grouped_by_date[enumerated_date]
				events_grouped_by_date[enumerated_date] << event
			end
		end

		events_grouped_by_date
	end

	def start_date
		if @start_date
			@start_date
		elsif options.has_key?(:start_date)
			options.fetch(:start_date).to_date
		else
			view_context.params.fetch(start_date_param, Date.current).to_date
		end
	end

	def end_date
		date_range.last
	end

	def additional_days
		options.fetch(:number_of_days, 4) - 1
	end

end