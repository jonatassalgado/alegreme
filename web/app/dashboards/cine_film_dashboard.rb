require "administrate/base_dashboard"

class CineFilmDashboard < Administrate::BaseDashboard
	# ATTRIBUTE_TYPES
	# a hash that describes the type of each of the model's fields.
	#
	# Each different type represents an Administrate::Field object,
	# which determines how the attribute is displayed
	# on pages throughout the dashboard.
	ATTRIBUTE_TYPES = {
		id:          Field::Number,
		cinemas:     Field::HasMany,
		screenings:  Field::HasMany,
		title:       Field::String.with_options,
		description: Field::Text.with_options(searchable: false),
		cover:       Field::String.with_options(searchable: false),
		genres:      Field::String.with_options(searchable: false),
		trailer:     Field::String.with_options(searchable: false),
		created_at:  Field::DateTime,
		updated_at:  Field::DateTime,
		image_data:  Field::Text,
		slug:        Field::String,
		type:        Field::String,
	}.freeze

	# COLLECTION_ATTRIBUTES
	# an array of attributes that will be displayed on the model's index page.
	#
	# By default, it's limited to four items to reduce clutter on index pages.
	# Feel free to add, remove, or rearrange items.
	COLLECTION_ATTRIBUTES = %i[
    id
    title
    genres
    created_at
  ].freeze

	# SHOW_PAGE_ATTRIBUTES
	# an array of attributes that will be displayed on the model's show page.
	SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    description
    trailer
    cover
    slug
    type
    cinemas
    screenings
    created_at
    updated_at
  ].freeze

	# FORM_ATTRIBUTES
	# an array of attributes that will be displayed
	# on the model's form (`new` and `edit`) pages.
	FORM_ATTRIBUTES = %i[
    title
    description
    trailer
    cover
    slug
    type
    cinemas
    screenings
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

	# Overwrite this method to customize how cine films are displayed
	# across all pages of the admin dashboard.
	#
	def display_resource(cine_film)
		"##{cine_film.id} #{cine_film.title}"
	end
end
