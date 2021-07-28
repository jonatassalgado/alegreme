require "administrate/base_dashboard"

class CinemaDashboard < Administrate::BaseDashboard
	# ATTRIBUTE_TYPES
	# a hash that describes the type of each of the model's fields.
	#
	# Each different type represents an Administrate::Field object,
	# which determines how the attribute is displayed
	# on pages throughout the dashboard.
	ATTRIBUTE_TYPES = {
		screenings:      Field::HasMany,
		movies:          Field::HasMany,
		id:              Field::Number,
		name:            Field::String,
		display_name:    Field::String,
		address:         Field::String,
		website:         Field::String,
		reference_place: Field::String,
		lower_price:     Field::Number,
		neighborhood:    Field::String,
		google_maps:     Field::String,
		slug:            Field::String,
		status:          Field::Enum,
		created_at:      Field::DateTime,
		updated_at:      Field::DateTime,
	}.freeze

	# COLLECTION_ATTRIBUTES
	# an array of attributes that will be displayed on the model's index page.
	#
	# By default, it's limited to four items to reduce clutter on index pages.
	# Feel free to add, remove, or rearrange items.
	COLLECTION_ATTRIBUTES = %i[
    id
    display_name
		updated_at
  ].freeze

	# SHOW_PAGE_ATTRIBUTES
	# an array of attributes that will be displayed on the model's show page.
	SHOW_PAGE_ATTRIBUTES = %i[
    screenings
    movies
    id
    status
    name
    display_name
    address
    website
		reference_place
		lower_price
		neighborhood
		google_maps
    slug
    created_at
    updated_at
  ].freeze

	# FORM_ATTRIBUTES
	# an array of attributes that will be displayed
	# on the model's form (`new` and `edit`) pages.
	FORM_ATTRIBUTES = %i[
    screenings
    movies
    status
    name
    display_name
    website
		reference_place
		lower_price
		neighborhood
		google_maps
    address
    slug
  ].freeze

	# COLLECTION_FILTERS
	# a hash that defines filters that can be used while searching via the search
	# field of the dashboard.
	#
	# For example to add an option to search for open resources by typing "open:"
	# in the search field:
	#
	#   COLLECTION_FILTERS = {
	#     open: ->(resources) { resources.where(open: true) }
	#   }.freeze
	COLLECTION_FILTERS = {}.freeze

	# Overwrite this method to customize how cinemas are displayed
	# across all pages of the admin dashboard.
	#
	def display_resource(cinema)
		"##{cinema.id} #{cinema.name}"
	end
end
