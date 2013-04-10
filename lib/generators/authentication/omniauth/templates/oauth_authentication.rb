module Strategies
  class OauthAuthentication < ::Warden::Strategies::Base
    def valid?
      request.env['omniauth.auth'].present?
    end

    def authenticate!
      auth = request.env['omniauth.auth']

      if authorized_domain?(auth)
        <%= resource_name %> = <%= resource_name.classify %>.find_<%= resource_name %>(auth['uid'], auth['provider']) || create_<%= resource_name %>(auth)
        return success! <%= resource_name %>
      end

      fail! I18n.t('sessions.create.unauthorized_domain')
    end

  private
    def authorized_domain?(auth)
      if Rails.application.config.respond_to?(:authentication_domain) && Rails.application.config.authentication_domain.present?
        return auth['info']['email'].split('@').last == Rails.application.config.authentication_domain
      end

      true
    end

    def create_<%= resource_name %>(auth)
      params = { uid: auth['uid'], provider: auth['provider'],
                name: auth['info']['name'], email: auth['info']['email'] }

      <%= resource_name.classify %>.create! params
    end
  end
end

Warden::Strategies.add(:oauth_authentication, Strategies::OauthAuthentication)
