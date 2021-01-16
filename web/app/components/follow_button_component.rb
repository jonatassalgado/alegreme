class FollowButtonComponent < ViewComponent::Base

	def initialize(followable:, user:)
		@followable = followable
		@user       = user
	end

end