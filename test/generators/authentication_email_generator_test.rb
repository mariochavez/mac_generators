require 'test_helper'
require 'generators/authentication/email/email_generator'

describe Authentication::Generators::EmailGenerator do
  include GeneratorsTestHelper

  before do
    copy_routes
    copy_locales
    copy_gemfile
    copy_application_controller
    make_migrations_dir
  end

  it 'copies controllers templates for user signup and session' do
    run_generator

    assert_file 'app/controllers/identities_controller.rb' do |m|
      assert_match 'IdentitiesController', m
      assert_match 'def new', m
      assert_match 'def create', m
    end

    assert_file 'app/controllers/sessions_controller.rb' do |m|
      assert_match 'SessionsController', m
      assert_match 'def new', m
      assert_match 'def create', m
      assert_match 'def destroy', m
    end
  end

  it 'copies user_controller template for user class' do
    run_generator ['user']

    assert_file 'app/controllers/users_controller.rb' do |m|
      assert_match 'UsersController', m
      assert_match 'def new', m
      assert_match 'def create', m
      assert_match '@user = User.new', m
    end
  end

  it 'copies erb templates' do
    run_generator

    assert_file 'app/views/identities/new.html.erb' do |m|
      assert_match 'form_for @identity', m
    end

    assert_file 'app/views/sessions/new.html.erb' do |m|
      assert_match 'form_tag sessions_path', m
    end
  end

  it 'copies haml templates' do
    run_generator ['--haml']

    assert_file 'app/views/identities/new.html.haml' do |m|
      assert_match 'form_for @identity', m
    end

    assert_file 'app/views/sessions/new.html.haml' do |m|
      assert_match 'form_tag sessions_path', m
    end
  end

  it 'add routes' do
    run_generator

    assert_file 'config/routes.rb' do |m|
      assert_match "get 'sign_up' => 'identities#new'", m
      assert_match "get 'log_in' => 'sessions#new'", m
      assert_match "get 'log_out' => 'sessions#destroy'", m

      assert_match "resource :identity, only: [:create, :new]", m
      assert_match "resource :sessions, only: [:create, :new]", m
    end
  end

  it 'generate migration' do
    Authentication::Generators::EmailGenerator.class_eval do
      def migration_name
        "create_#{resource_pluralize}.rb"
      end
    end

    run_generator

    assert_file 'db/migrate/create_identities.rb' do |m|
      assert_match 'create_table :identities', m
      assert_match 't.string :email', m
      assert_match 't.string :password_hash', m
      assert_match 't.string :password_salt', m
    end

    assert_file 'app/models/identity.rb' do |m|
      assert_match 'class Identity < ActiveRecord::Base', m
      assert_match 'has_secure_password validations: true', m
    end
  end

  it 'add helper methods to application controller' do
    run_generator

    assert_file 'app/controllers/application_controller.rb' do |m|
      assert_match 'helper_method :current_identity, :identity_signed_in?', m
      assert_match 'def current_identity', m
      assert_match 'def identity_signed_in?', m
      assert_match 'def authenticate!', m
    end
  end

  it 'add warden gem to Gemfile' do
    run_generator

    assert_file 'Gemfile' do |m|
      assert_match "gem \"warden\", \"~> 1.2.0\"", m
      assert_match "gem \"bcrypt-ruby\"", m
    end
  end

  it 'copy warden configuration' do
    run_generator

    assert_file 'config/initializers/warden.rb' do |m|
      assert_match 'manager.default_strategies :database_authentication', m
      assert_match 'Warden::Manager.serialize_into_session(:identity)', m
      assert_match 'Warden::Manager.serialize_from_session(:identity)', m
    end
  end

  it 'copy warden strategies' do
    run_generator

    assert_file 'lib/strategies/database_authentication.rb' do |m|
      assert_match 'def valid?', m
      assert_match 'authenticate!', m
    end
  end
end

