ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"
require "rails"
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

# Create a test controller for view specs
class ApplicationController < ActionController::Base
end

# Load the gem
require "chobble-forms"

# Create a minimal Rails application for testing
module ChobbleFormsTest
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "test-secret-key-base"
    
    # Set the root to the gem directory to avoid loading parent app config
    config.root = Pathname.new(__dir__).parent

    # Minimal middleware stack
    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Session::CookieStore
    config.middleware.delete ActionDispatch::Flash

    # Add a simple rack app
    config.middleware.use Rack::Runtime

    # Add routes for minimal functionality
    routes.append do
      root to: proc { [200, {}, ["OK"]] }
    end
  end
end

# Initialize the Rails application
Rails.application.initialize!

# Now require rspec-rails and capybara after Rails is initialized
require "rspec/rails"
require "capybara/rspec"

# Include I18n test helpers
I18n.load_path += Dir[File.expand_path("../fixtures/locales/*.yml", __FILE__)]
I18n.default_locale = :en
I18n.backend.reload!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include ChobbleForms::Helpers, type: :view
  config.include Capybara::RSpecMatchers, type: :view

  # Clear I18n backend between tests
  config.before(:each) do
    I18n.backend.reload!
  end
end
