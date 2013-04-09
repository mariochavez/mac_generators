Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :database_authentication

  # TODO: Setup warden's failure app, this will be called everytime that
  # and authentication failure happen.
  # Failure app should be a Rack application.
  # In Rails a controller can be used as a Rack app, just specify the
  # controller and the action to be called. Example:
  #
  #manager.failure_app = lambda { |env| DashboardController.action(:index).call(env) }
end

Warden::Manager.serialize_into_session(:<%= resource_name %>) do |<%= resource_name %>|
  <%= resource_name %>.id
end

Warden::Manager.serialize_from_session(:<%= resource_name %>) do |id|
  <%= resource_name.classify %>.find(id)
end
