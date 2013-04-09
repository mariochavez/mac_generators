module Authentication
  module Generators
    class EmailGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :resource_name, :type => :string, :default => 'identity'
      class_option :haml, type: :boolean, default: false, description: 'Generate haml templates'

      def copy_controller_files
        template 'identities_controller.rb', File.join('app/controllers', "#{resource_pluralize}_controller.rb")
        template 'sessions_controller.rb', 'app/controllers/sessions_controller.rb'
      end

      def copy_view_files
        if options[:haml]
          template 'haml/identity_new.html.haml', "app/views/#{resource_pluralize}/new.html.haml"
          template 'haml/session_new.html.haml', "app/views/sessions/new.html.haml"
        else
          template 'erb/identity_new.html.erb', "app/views/#{resource_pluralize}/new.html.erb"
          template 'erb/session_new.html.erb', "app/views/sessions/new.html.erb"
        end
      end

      def add_routes
        route "get 'sign_up' => '#{resource_pluralize}#new', as: :sign_up"
        route "get 'log_in' => 'sessions#new', as: :log_in"
        route "get 'log_out' => 'sessions#destroy', as: :log_out"

        route "resource :#{resource_name}, only: [:create, :new]"
        route "resource :sessions, only: [:create, :new]"
      end

      def generate_user
        if Dir["db/migrate/*create_#{resource_pluralize}.rb"].empty?
          template 'create_identities.rb', "db/migrate/#{migration_name}"
        end
        template 'identity.rb', "app/models/#{resource_name}.rb"
      end

      def add_helper_methods
        insert_into_file 'app/controllers/application_controller.rb', after: /:exception/ do
    <<-EOS


  helper_method :current_#{resource_name}, :#{resource_name}_signed_in?

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

  def warden
    request.env['warden']
  end
    EOS
        end

      end

    def add_gems
      gem 'warden', '~> 1.2.0'
    end

    def add_translations
      insert_into_file "config/locales/en.yml", after: 'en:' do
  <<-EOS

    sessions:
      new:
        log_in: 'Log in'
      create:
        invalid_credentials: 'Your credentials are invalid'
        logged_in: 'Welcome back!'
      destroy:
        logged_out: 'See you later!'
    #{resource_pluralize}:
      new:
        create: 'Create #{resource_name}'
      create:
        sign_up: 'Welcome to your new account!'
  EOS
      end
    end

    def copy_warden_file
      template 'warden.rb', File.join('config', 'initializers', 'warden.rb')
    end

    def copy_warden_strategies
      template 'database_authentication.rb', File.join('lib', 'strategies', 'database_authentication.rb')
    end

    def instructions
    end

    private
      def migration_name
        date = (DateTime.now.strftime "%Y %m %d %H %M %S").gsub(' ', '')
        "#{date}_create_#{resource_pluralize}.rb"
      end

      def resource_pluralize
        @resource_pluralize ||= resource_name.pluralize
      end
    end
  end
end
