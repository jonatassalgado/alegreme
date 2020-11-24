class LeftSidebar::HorizontalEventComponent < ViewComponentReflex::Component
	with_collection_parameter :event

	def initialize(event:, user:, parent_key: nil)
		@parent_key = parent_key
		@event      = event
		@user       = user
	end

	def unlike
		@user.unlike! @event
		# stimulate 'LeftSidebar::MyAgendaComponent#update', {key: @parent_key}
		refresh! '#my-agenda', '#main-sidebar__group-by-day-list', '#right-sidebar'
	end

	def collection_key
		@event.id
	end

end