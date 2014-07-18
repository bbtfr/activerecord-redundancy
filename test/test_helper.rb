# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'minitest/autorun'
# require 'pry-rescue/minitest'

require 'support/environment.rb'
require 'redundancy'
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)

# Load fixtures from the engine
class ActiveSupport::TestCase
  fixtures :all
end
