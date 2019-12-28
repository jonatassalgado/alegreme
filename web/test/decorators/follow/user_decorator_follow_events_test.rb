require 'test_helper'

class UserDecoratorFollowEventsTest < ActiveSupport::TestCase
	def setup
		# @event = create(:event)
	end

	test "events_from_followed_features" do
		context 'exist 2 events from features followed' do |context|
			#user    = create(:user)
			#event_a = create(:event)
			#event_b = create(:event, details: {name: 'Feira do Livro'})
			#
			#organizer_a = create(:organizer)
			#organizer_b = create(:organizer, details: {name: 'Mario Quintana'})
			#category_a  = create(:category)
			#category_b  = create(:category, details: {name: 'show'})
			#
			#event_a.organizers << [organizer_a, organizer_b]
			#event_a.categories << [category_a, category_b]
			#event_b.organizers << organizer_a
			#
			#user.follow(organizer_a)
			#user.follow(organizer_b)
			#user.follow(category_a)

			#assert_equal 2, user.events_from_following_topics.count, "#{context} -> should return all events with same features liked"
		end

		context 'exist 1 event from features followed' do |context|
			#user    = create(:user)
			#event_a = create(:event)
			#
			#organizer_a = create(:organizer)
			#organizer_b = create(:organizer, details: {name: 'Mario Quintana'})
			#category_a  = create(:category)
			#category_b  = create(:category, details: {name: 'show'})
			#
			#event_a.organizers << [organizer_a, organizer_b]
			#event_a.categories << [category_a, category_b]
			#
			#user.follow(organizer_a)
			#user.follow(organizer_b)
			#user.follow(category_a)

			#assert_equal 1, user.events_from_following_topics.count, "#{context} -> should return all events with same features liked"
		end
	end
end
