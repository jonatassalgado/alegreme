require 'test_helper'
require_relative '../../../app/services/follow_services/association_creator'

class AssociationCreatorTest < ActiveSupport::TestCase
	# def setup
	# 	@user = create(:user)
	# end
	#
	# test 'should create association between user and organizer' do
	# 	organizer    = create(:organizer)
	#
	# 	association = FollowServices::AssociationCreator.new(@user, organizer).call
	#
	# 	assert association, 'should save organizer and user with success'
	# 	assert_includes organizer.followers, @user.id, 'should includes user.id in organizer followers'
	# 	assert_includes organizer.followers, @user.id, 'should accept only uniq associations'
	# end
	#
	# test 'should destroy association between user and organizer' do
	# 	organizer    = create(:organizer)
	#
	# 	association = FollowServices::AssociationCreator.new(@user, organizer).call
	#
	# 	assert association, 'should save organizer and user with success'
	# 	assert_includes organizer.followers, @user.id, 'should includes user.id in organizer followers'
	# 	assert_includes organizer.followers, @user.id, 'should accept only uniq associations'
	#
	# 	association = FollowServices::AssociationCreator.new(@user, organizer).call(destroy: true)
	# 	assert association, 'should remove association with organizer and user with success'
	# 	refute_includes organizer.followers, @user.id, 'should not includes user.id in organizer followers'
	# end

end
