# frozen_string_literal: true

class MainSidebar::LargeEventReflex < ApplicationReflex

	def open
		@event          = Event.find(args['event_id'])
		@similar_events = Event.includes(:place).active.where(id: @event.similar_data).order_by_ids(@event.similar_data).limit(6)
	end

	def close
		@event = nil
	end
end