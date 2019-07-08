ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'database_cleaner'
require 'awesome_print'
require 'devise'

# include Devise::Test::ControllerHelpers
# include Devise::Test::IntegrationHelpers
include FactoryBot::Syntax::Methods


DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

class ActionDispatch::IntegrationTest
  def setup
    DatabaseCleaner.start
  end

  fixtures :all

  def teardown
    Timecop.return
    DatabaseCleaner.clean
  end

  def context(should, &block)
    block.call(should.upcase)
  end

  def is(action, &block)
    block.call(action.upcase)
  end

  def sign_in(user)
    post user_session_path \
      "user[email]"    => user.email,
      "user[password]" => user.password
  end

end


class ActiveSupport::TestCase
  def setup
    DatabaseCleaner.start
  end

  fixtures :all

  def teardown
    Timecop.return
    DatabaseCleaner.clean
  end

  def context(should, &block)
    block.call(should.upcase)
  end

  def is(action, &block)
    block.call(action.upcase)
  end

end
