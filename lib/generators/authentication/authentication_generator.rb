class AuthenticationGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)
  argument :resource_name, :type => :string, :default => 'identity'
  class_option :haml, type: :boolean, default: false, description: 'Generate haml templates'

  def copy_controller_files
    template 'identities_controller.rb', "app/controllers/#{resource_pluralize}_controller.rb"
    template 'sessions_controller.rb', 'app/controllers/sessions_controller.rb'
  end

  def copy_view_files
    puts ">>>#{options}"
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


  helper_method :current_#{resource_name}

private
  def current_#{resource_name}
    @current_#{resource_name} ||= #{resource_name.classify}.find(session[:#{resource_name}_id]) if session[:#{resource_name}_id]
  end
EOS
    end

  end

  def add_gems
    gem 'bcrypt-ruby', require: 'bcrypt'
  end

  def add_translations
    insert_into_file "config/locales/#{I18n.default_locale.to_s}.yml", after: 'en:' do
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

private
  def resource_pluralize
    @resource_pluralize ||= resource_name.pluralize
  end

  def migration_name
    date = (DateTime.now.strftime "%Y %m %d %H %M %S").gsub(' ', '')
    "#{date}_create_#{resource_pluralize}.rb"
  end
end
