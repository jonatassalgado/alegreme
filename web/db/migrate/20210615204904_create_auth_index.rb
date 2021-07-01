# https://github.com/lynndylanhurley/devise_token_auth/issues/544
class CreateAuthIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :users, [:uid, :provider], unique: true
  end
end
