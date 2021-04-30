require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    likes: Field::HasMany,
    liked_or_disliked_events: Field::HasMany,
    liked_events: Field::HasMany,
    disliked_events: Field::HasMany,
    friendships: Field::HasMany,
    friendships_requested: Field::HasMany,
    friendships_request_received: Field::HasMany,
    friends_requested: Field::HasMany,
    friends_requested_received: Field::HasMany,
    follows: Field::HasMany,
    following_relationships: Field::HasMany,
    following_users: Field::HasMany,
    following_places: Field::HasMany,
    following_organizers: Field::HasMany,
    following_places_events: Field::HasMany,
    following_organizers_events: Field::HasMany,
    following_users_events: Field::HasMany,
    places_from_liked_events: Field::HasMany,
    organizers_from_liked_events: Field::HasMany,
    id: Field::Number,
    email: Field::String,
    encrypted_password: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    features: Field::JSONB,
    taste: Field::JSONB,
    suggestions: Field::JSONB,
    admin: Field::Boolean,
    notifications: Field::JSONB,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
    slug: Field::String,
    image_data: Field::String.with_options(searchable: false),
    swipable: Field::JSONB,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    likes
    liked_or_disliked_events
    liked_events
    disliked_events
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    likes
    liked_events
    disliked_events
    friendships
    friendships_requested
    friendships_request_received
    friends_requested
    friends_requested_received
    follows
    following_relationships
    following_users
    following_places
    following_organizers
    id
    email
    encrypted_password
    reset_password_token
    reset_password_sent_at
    remember_created_at
    created_at
    updated_at
    features
    taste
    suggestions
    admin
    notifications
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    current_sign_in_ip
    last_sign_in_ip
    slug
    image_data
    swipable
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    likes
    liked_or_disliked_events
    liked_events
    disliked_events
    friendships
    friendships_requested
    friendships_request_received
    friends_requested
    friends_requested_received
    follows
    following_relationships
    following_users
    following_places
    following_organizers
    following_places_events
    following_organizers_events
    following_users_events
    places_from_liked_events
    organizers_from_liked_events
    email
    encrypted_password
    reset_password_token
    reset_password_sent_at
    remember_created_at
    features
    taste
    suggestions
    admin
    notifications
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    current_sign_in_ip
    last_sign_in_ip
    slug
    image_data
    swipable
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

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
