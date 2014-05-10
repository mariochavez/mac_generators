# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/focus"
#require "minitest/colorize"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

require 'rails/generators/test_case'
class Rails::Generators::TestCase
  register_spec_type(self) do |desc|
    Class === desc && desc < Rails::Generators::Base
  end

  register_spec_type(/Generator( ?Test)?\z/i, self)

  def self.determine_default_generator(name)
    generator = determine_constant_from_test_name(name) do |constant|
      Class === constant && constant < Rails::Generators::Base
    end
    raise NameError.new("Unable to resolve generator for #{name}") if generator.nil?
    generator
  end
end
