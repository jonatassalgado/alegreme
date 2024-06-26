require 'test_helper'
require_relative '../../../app/services/event_services/similar_fetcher'

class SimilarCreatorTest < ActiveSupport::TestCase
	def setup
		@user = build(:user)

		@events_dogs = []
		@events_cats = []

		5.times do |index|
			@events_dogs << build(:event, ml_data: {
					'stemmed': "os cachorros são caninos e o cachorro come ração #{index}",
			})
		end

		5.times do |index|
			@events_cats << build(:event, ml_data: {
					'stemmed': "os gatos são felinos e o gato come queijo #{index}",
			})
		end
	end


	test 'similar of events' do
		context "when requested of 1 event" do
			# Arrange
			events_base               = @events_dogs + @events_cats
			event_to_found_similar    = @events_dogs.first
			event_to_found_similar_id = event_to_found_similar.id

			# Action
			action = EventServices::SimilarFetcher.new([event_to_found_similar], events_base).call

			# Assert
			assert_equal true, action[:all_success], "should return success"
			assert_equal 9, action[:resources][event_to_found_similar_id][:similar].count, "should return 9 events similar"
		end

		context "when requested of 2 events" do
			# Arrange
			events_base             = @events_dogs + @events_cats
			events_to_found_similar = [@events_dogs.first, @events_cats.first]

			# Action
			action = EventServices::SimilarFetcher.new(events_to_found_similar, events_base).call

			# Assert
			assert_equal true, action[:all_success], "should return success"
			assert_equal 2, action[:resources].size, "should return 3 keys in response"
			assert_equal 9, action[:resources][events_to_found_similar[0].id][:similar].size, "should return 9 similar events for first event"
			assert_equal 9, action[:resources][events_to_found_similar[1].id][:similar].size, "should return 9 similar events for second event"
		end

		context "when requested a mixed suggestion" do
			# Arrange
			events_base             = @events_dogs + @events_cats
			events_to_found_similar = [@events_dogs.first, @events_cats.first]

			# Action
			action = EventServices::SimilarFetcher.new(events_to_found_similar, events_base).call(mixed_suggestions: true)

			# Assert
			assert_equal 10, action[:mixed_suggestions].size, "should return 10 mixed suggestions"
		end

		# context "when requested a mixed suggestion with 5 qty" do
		# 	# Arrange
		# 	events_base             = @events_dogs + @events_cats
		# 	events_to_found_similar = [@events_dogs.first, @events_cats.first]
		#
		# 	# Action
		# 	action = EventServices::SimilarFetcher.new(events_to_found_similar, events_base).call({
		# 			                                                                                      mixed_suggestions: true,
		# 			                                                                                      mixed_suggestions_qty: 4
		# 	                                                                                      })
		#
		# 	# Assert
		# 	assert_equal 8, action[:mixed_suggestions].size, "should return 8 mixed suggestions, 4 of each event requested"
		# end
	end


end
