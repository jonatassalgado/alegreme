require 'test_helper'

class UserDecoratorFollowOrganizersTest < ActiveSupport::TestCase
	def setup
	end

	test "following_organizers" do
		context 'following 2 organizers' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			organizer_a = create(:organizer)
			organizer_b = create(:organizer)

			user.follow_organizer(organizer_a)
			user.follow_organizer(organizer_b)

			assert_equal 2, user.following['organizers_total_follows'], "#{context} -> should return 2"
			assert_equal 1, organizer_a.followers['users_total_followers'], "#{context} -> should return 1"
			assert_equal [user.id], organizer_a.followers['users'], "#{context} -> should return user id"
		end
	end

	test "unfollowing_organizers" do
		context 'unfollowing 1 organizer' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			organizer_a = create(:organizer)
			organizer_b = create(:organizer)

			user.follow_organizer(organizer_a)
			user.follow_organizer(organizer_b)
			user.unfollow_organizer(organizer_b)

			assert_equal 1, user.following['organizers_total_follows'], "#{context} -> should return 2"
			assert_equal 1, organizer_a.followers['users_total_followers'], "#{context} -> should return 1"
			assert_equal [user.id], organizer_a.followers['users'], "#{context} -> should return user id"
		end
	end
end
