class ModalComponent < ViewComponent::Base
	def initialize(opened: false, title: nil, text: nil, action: nil)
		@opened = opened
		@title  = title
		@text   = text
		@action = action
	end

end

