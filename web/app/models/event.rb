class Event < ApplicationRecord

	extend FriendlyId
	friendly_id :slug_candidates, use: :slugged

	def slug_candidates
		[
				[:details_name, :categories_primary_name],
				[:details_name, :place_details_name, :categories_primary_name],
				[:details_name, :place_details_name, :categories_primary_name, :first_day_time]
		]
	end

	include ImageUploader::Attachment.new(:image)
	include Rails.application.routes.url_helpers

	include EventDecorators::Details
	include EventDecorators::Geographic
	include EventDecorators::Ocurrences
	include EventDecorators::Theme
	include EventDecorators::Personas
	include EventDecorators::Categories
	include EventDecorators::Tags
	include EventDecorators::Kinds
	include EventDecorators::MLData

	include EventQueries::Scopes

	acts_as_followable

	# validate :validate_attrs_that_should_be_a_hash
	# validate :validate_attrs_that_should_be_a_array

	# after_save :reindex, if: proc { |event| event.details_changed? }
	# after_destroy :reindex, :destroy_entries

	belongs_to :place
	has_and_belongs_to_many :organizers
	has_and_belongs_to_many :categories
	# has_and_belongs_to_many :kinds

	accepts_nested_attributes_for :place, :organizers

	delegate :details_name, to: :place, prefix: true, allow_nil: true

	searchkick callbacks: false, language: 'portuguese', highlight: %i[details_name]

	def search_data
		{
				name:        details_name,
				description: ml_data_cleanned,
				category:    categories_primary_name,
				place:       place_details_name,
				organizers:  organizers.map(&:details_name)
		}
	end

	def ml_data_all
		nouns = ml_data['nouns']
		verbs = ml_data['verbs']
		adjs  = ml_data['adjs']

		nouns.union(verbs, adjs)
	end


	def cover_url(type = :list)
		image[type].url if image && image[type].exists?
	end

	def url
		event_path(self)
	end

	def first_day_time
		ocurrences['dates'].first
	end


	def datetimes
		datetimes = []

		ocurrences['dates'].each_with_index do |date, _index|
			datetimes << DateTime.parse(date).strftime('%Y-%m-%d %H:%M:%S')
		end

		datetimes
	end


	private

	def destroy_entries
		users = User.where id: saved_by

		users.each do |user|
			user.taste['events']['saved'].delete id
			user.taste['events']['total_saves'] -= 1
		end
	end

end
