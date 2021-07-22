class LikesButtonComponent < ViewComponent::Base

	def initialize(likeable:, user:, template: 'button')
		@likeable = likeable
		@user     = user
		@template = template
	end

	def render?
		@likeable.present?
	end

end