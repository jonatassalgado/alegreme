require 'test_helper'



class UserDecoratorFollowUsersTest < ActiveSupport::TestCase
	def setup

	end

	test "follow_user" do
		context 'following 2 users' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			user_a = create(:user, features: {demographic: {name: 'Bastos'}})
			user_b = create(:user, features: {demographic: {name: 'Txai'}})

			user.follow_user(user_a)
			user.follow_user(user_b)

			assert_equal 2, user.following['users_total_follows'], "#{context} -> should return 2"
			assert_equal 1, user_a.followers['users_total_followers'], "#{context} -> should return 1"
			assert_equal [user.id], user_a.followers['users'], "#{context} -> should return user id"
		end

		context 'repeated users following' do |context|
			it 'cannot return duplicate' do
				user   = create(:user, features: {demographic: {name: 'Jon'}})
				user_a = create(:user, features: {demographic: {name: 'Bastos'}})
				user_b = create(:user, features: {demographic: {name: 'Txai'}})

				user.follow_user(user_a)
				user.follow_user(user_a)
				user.follow_user(user_b)

				assert_equal 2, user.following['users_total_follows'], "#{context} -> should return 2"
				assert_equal 1, user_a.followers['users_total_followers'], "#{context} -> should return 1"
			end
		end
	end

	test "unfollow_user" do
		context 'unfollowing 2 users' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			user_a = create(:user, features: {demographic: {name: 'Bastos'}})
			user_b = create(:user, features: {demographic: {name: 'Txai'}})

			user.follow_user(user_a)
			user.follow_user(user_b)

			user.unfollow_user(user_a)

			assert_equal 1, user.following['users_total_follows'], "#{context} -> should return 1"
			assert_equal [user_b.id], user.following['users'], "#{context} -> should return user_b id"
			assert_equal 0, user_a.followers['users_total_followers'], "#{context} -> should return 0"
			assert_equal [], user_a.followers['users'], "#{context} -> should return empty array"
		end

		context 'unfollowing repetead users' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			user_a = create(:user, features: {demographic: {name: 'Bastos'}})
			user_b = create(:user, features: {demographic: {name: 'Txai'}})

			user.follow_user(user_a)
			user.follow_user(user_b)

			user.unfollow_user(user_a)

			assert_nothing_raised do
				user.unfollow_user(user_a)
			end
		end
	end

	test "following_users" do
		context 'following 3 users' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			user_a = create(:user, features: {demographic: {name: 'Bastos'}})
			user_b = create(:user, features: {demographic: {name: 'Txai'}})
			user_c = create(:user, features: {demographic: {name: 'Daniel'}})

			user.follow_user(user_a)
			user.follow_user(user_b)
			user.follow_user(user_c)

			assert_equal [user_a.id, user_b.id, user_c.id], user.following_users, "#{context} -> should return users followed"
		end
	end

	test "following_user?" do
		context 'following user_a' do |context|
			user   = create(:user, features: {demographic: {name: 'Jon'}})
			user_a = create(:user, features: {demographic: {name: 'Bastos'}})
			user_b = create(:user, features: {demographic: {name: 'Txai'}})

			user.follow_user(user_a)

			assert_equal true, user.following_user?(user_a), "#{context} -> should return true"
		end
	end
end
