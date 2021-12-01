require "administrate/base_dashboard"

class CineFilmDashboard < Administrate::BaseDashboard
	# ATTRIBUTE_TYPES
	# a hash that describes the type of each of the model's fields.
	#
	# Each different type represents an Administrate::Field object,
	# which determines how the attribute is displayed
	# on pages throughout the dashboard.
	ATTRIBUTE_TYPES = {
		id:               Field::Number,
		cinemas:          Field::HasMany,
		screening_groups: Field::HasMany,
		image:            Field::Shrine.with_options(version: :small),
		title:            Field::String.with_options,
		description:      Field::Text.with_options(searchable: false),
		cover:            Field::String.with_options(searchable: false),
		genres:           Field::JSONB.with_options(blank_sign: [], transform: true),
		trailer:          Field::String.with_options(searchable: false),
		created_at:       Field::DateTime,
		updated_at:       Field::DateTime,
		image_data:       Field::Text.with_options(searchable: false),
		slug:             Field::String.with_options(searchable: false),
		type:             Field::String,
		status:           Field::Enum,
		rating:           Field::Number,
		age_rating:       Field::String.with_options(searchable: false),
		cast:             Field::JSONB.with_options(blank_sign: [], transform: true),
		year:             Field::Number
	}.freeze

	# COLLECTION_ATTRIBUTES
	# an array of attributes that will be displayed on the model's index page.
	#
	# By default, it's limited to four items to reduce clutter on index pages.
	# Feel free to add, remove, or rearrange items.
	COLLECTION_ATTRIBUTES = %i[
    id
    image
    title
    trailer
    created_at
    updated_at
  ].freeze

	# SHOW_PAGE_ATTRIBUTES
	# an array of attributes that will be displayed on the model's show page.
	SHOW_PAGE_ATTRIBUTES = %i[
    id
    status
		image
    title
    genres
    description
    trailer
    rating
    age_rating
    cast
    year
    cover
    slug
    type
    cinemas
    screening_groups
    created_at
    updated_at
  ].freeze

	# FORM_ATTRIBUTES
	# an array of attributes that will be displayed
	# on the model's form (`new` and `edit`) pages.
	FORM_ATTRIBUTES = %i[
		status
	  image
    title
    genres
    description
    trailer
    rating
    age_rating
    cast
    year
    cover
    slug
    type
    cinemas
    screening_groups
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
