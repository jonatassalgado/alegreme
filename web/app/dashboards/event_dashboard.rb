require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard

	# ATTRIBUTE_TYPES
	# a hash that describes the type of each of the model's fields.
	#
	# Each different type represents an Administrate::Field object,
	# which determines how the attribute is displayed
	# on pages throughout the dashboard.
	ATTRIBUTE_TYPES = {
		image:          Field::Shrine.with_options(version: :feed),
		place:          Field::BelongsTo,
		organizers:     Field::HasMany,
		categories:     Field::HasMany,
		likes:          Field::HasMany,
		users:          Field::HasMany,
		id:             Field::Number,
		description:    TrixField,
		theme:          Field::JSONB,
		datetimes:      CalendarField,
		name:           Field::String.with_options(searchable: true),
		entries:        Field::JSONB,
		ml_data:        Field::JSONB,
		similar_data:   Field::JSONB,
		image_data:     Field::JSONB,
		created_at:     Field::DateTime,
		updated_at:     Field::DateTime,
		slug:           Field::String.with_options(searchable: false),
		ticket_url:     Field::String.with_options(searchable: false),
		source_url:     Field::String.with_options(searchable: true),
		multiple_hours: Field::Boolean,
		status:         Field::Enum
	}.freeze

	# COLLECTION_ATTRIBUTES
	# an array of attributes that will be displayed on the model's index page.
	#
	# By default, it's limited to four items to reduce clutter on index pages.
	# Feel free to add, remove, or rearrange items.
	COLLECTION_ATTRIBUTES = %i[
    id
    image
    name
    status
    updated_at
  ].freeze

	# SHOW_PAGE_ATTRIBUTES
	# an array of attributes that will be displayed on the model's show page.
	SHOW_PAGE_ATTRIBUTES = %i[
  	status
  	image
  	multiple_hours
    place
    organizers
    categories
    id
    name
    description
    theme
    datetimes
    ticket_url
    source_url
    entries
    ml_data
    similar_data
    image_data
    created_at
    updated_at
    slug
  ].freeze

	# FORM_ATTRIBUTES
	# an array of attributes that will be displayed
	# on the model's form (`new` and `edit`) pages.
	FORM_ATTRIBUTES = %i[
    status
    image
    multiple_hours
    place
    organizers
    categories
    name
    description
    datetimes
    ticket_url
    source_url
    ml_data
    similar_data
    slug
  ].freeze

	# COLLECTION_FILTERS
	# a hash that defines filters that can be used while searching via the search
	# field of the dashboard.
	#
	# For example to add an option to search for open resources by typing "open:"
	# in the search field:
	#
	COLLECTION_FILTERS = {
		active: ->(resources) { resources.active },
		today:  ->(resources) { resources.in_day(DateTime.now) }
	}.freeze
	# COLLECTION_FILTERS = {}.freeze

	# Overwrite this method to customize how events are displayed
	# across all pages of the admin dashboard.
	#
	# def display_resource(event)
	#   "Event ##{event.id}"
	# end
end
