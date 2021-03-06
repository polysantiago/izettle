require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true

    def test_sign_in(user)
      controller.sign_in(user)
    end
    
    def test_sign_out
      controller.sign_out
    end
  end
  
  # Webrat configuration
  Webrat.configure do |config|
    config.mode = :rails
  end
end
Spork.each_run do
end