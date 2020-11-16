class Modal::SignInComponent < ViewComponentReflex::Component
  def initialize(key: nil, opened: false, text: nil)
    @opened = opened
    @text   = text
    @key    = key
  end

  def open
    @opened = true
  end

  def close
    @opened = false
  end

end

