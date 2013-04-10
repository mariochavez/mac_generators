module Strategies
  class DatabaseAuthentication < ::Warden::Strategies::Base
    def valid?
      params['<%= resource_name %>'].present?
    end

    def authenticate!
      <%= resource_name %> = <%= resource_name.classify %>.find_by_email(params['<%= resource_name %>']['email']).try(:authenticate, params['<%= resource_name %>']['password'])

      return success! <%= resource_name %> if <%= resource_name %>
      fail! I18n.t('login_errors.message')

    end
  end
end

Warden::Strategies.add(:database_authentication, Strategies::DatabaseAuthentication)
