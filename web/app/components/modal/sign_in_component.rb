class Modal::SignInComponent < ViewComponent::Base
  def initialize(opened: false, text: nil)
    @opened = opened
    @text   = text
  end

end

