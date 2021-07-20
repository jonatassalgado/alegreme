class FollowButtonComponent < ViewComponent::Base

	def initialize(followable:, user:, type: 'button')
		@followable = followable
		@user       = user
		@type       = type
	end

	def render?
		@followable.present?
	end

end