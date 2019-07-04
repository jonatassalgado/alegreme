require 'test_helper'

class FollowControllerTest < ActionDispatch::IntegrationTest
	def setup
		@user = create(:user)
		sign_in @user
	end

	test "should get index with success" do
		Timecop.freeze('2019-05-28 12:00:00')

		@event = create(:event_with_organizers)
		# byebug
		get(follow_url('organizers', @event.organizers.first.id), params: {event_id: @event.id} , xhr: true)

		assert_response :success, 'should load follow create with success'
		# assert_includes @event.organizers.first.followers, @user.id, 'should save user follower id in organizer'
		# assert_includes User.last.following['organizers'], @event.organizers.first.id, 'should save organizer id in user following'
	end


end
