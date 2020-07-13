module Authentication
  module Generators
    class OmniauthGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      argument :resource_name, type: :string, default: "identity"

      def copy_controller_files
        template "sessions_controller.rb", "app/controllers/sessions_controller.rb"
      end

      def add_routes
        route "get 'auth/:provider/callback', to: 'sessions#create', as: :log_in"
        route "delete '/sessions/destroy', to: 'sessions#destroy', as: :log_out"
      end

      def generate_user
        if Dir["db/migrate/*create_#{resource_pluralize}.rb"].empty?
          template "create_identities.rb", "db/migrate/#{migration_name}"
        end
        template "identity.rb", "app/models/#{resource_name}.rb"
      end

      def add_helper_methods
        insert_into_file "app/controllers/application_controller.rb", after: /:exception/ do
          <<~EOS


              helper_method :current_#{resource_name}, :#{resource_name}_signed_in?, :warden_message

              protected

              def current_#{resource_name}
                warden.user(scope: :#{resource_name})
              end

              def #{resource_name}_signed_in?
                warden.authenticate?(scope: :#{resource_name})
              end

              def authenticate!
                redirect_to root_path, notice: t('.not_logged') unless #{resource_name}_signed_in?
              end

              def warden_message
                warden.message
              end

              def warden
                request.env['warden']
              end
          EOS
        end
      end

      def add_gems
        gem "warden", "~> 1.2.0"
        gem "omniauth"
      end

      def add_translations
        insert_into_file "config/locales/en.yml", after: "en:" do
          <<-EOS

  sessions:
    new:
      log_in: 'Log in'
    create:
      unauthorized_domain: 'Sorry but your domain is not authorized'
      logged_in: 'Welcome back!'
    destroy:
      logged_out: 'See you later!'
          EOS
        end
      end

      def copy_warden_file
        template "warden.rb", File.join("config", "initializers", "warden.rb")
      end

      def copy_configuration
        template "authentication_domain.rb", File.join("config", "initializers", "authentication_domain.rb")
      end

      def copy_omniauth_configuration
        template "omniauth.rb", File.join("config", "initializers", "omniauth.rb")
      end

      def copy_warden_strategies
        template "oauth_authentication.rb", File.join("lib", "strategies", "oauth_authentication.rb")
      end

      def instructions
        message = "There are a few manual steps that you need to take care of\n\n"
        message << "1. Add an omniauth provider gem like twitter, facebook, etc..\n"
        message << "2. Modify config/initializers/omniauth.rb and setup your provider\n"
        message << "   and your provider credentials.\n"
        message << "3. Run bundle command to install new gems.\n"
        message << "4. If you want to restrict access to a specific email domain.\n"
        message << "   modify config/initializers/authentication_domain.rb and add \n"
        message << "   your allowed domain.\n"
        message << "5. Inspect warden initializer at config/initializers/warden.rb\n"
        message << "   and update the failure_app.\n"
        message << "6. Be sure that to have definition for root in your routes.\n"
        message << "7. Run rake db:migrate to add your #{resource_pluralize} table.\n"
        message << "8. Inspect generated files and learn how authentication was implemented.\n\n"

        puts message
      end

      private

      def migration_name
        date = (DateTime.now.strftime "%Y %m %d %H %M %S").delete(" ")
        "#{date}_create_#{resource_pluralize}.rb"
      end

      def resource_pluralize
        @resource_pluralize ||= resource_name.pluralize
      end
    end
  end
end
