# https://github.com/lynndylanhurley/devise_token_auth/issues/544
class SetUidForUsers < ActiveRecord::Migration[6.0]
  def self.up
    User.update_all("uid=email")
  end

  def self.down
  end
end
