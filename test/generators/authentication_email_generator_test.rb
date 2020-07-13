require "test_helper"
require "generators/authentication/email/email_generator"

class Authentication::Generators::EmailGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  setup do
    copy_routes
    copy_locales
    copy_gemfile
    copy_application_controller
    make_migrations_dir
  end

  test "it copies controllers templates for user signup and session" do
    run_generator

    assert_file "app/controllers/identities_controller.rb" do |m|
      assert_match "IdentitiesController", m
      assert_match "def new", m
      assert_match "def create", m
    end

    assert_file "app/controllers/sessions_controller.rb" do |m|
      assert_match "SessionsController", m
      assert_match "def new", m
      assert_match "def create", m
      assert_match "def destroy", m
    end
  end

  test "it copies user_controller template for user class" do
    run_generator ["user"]

    assert_file "app/controllers/users_controller.rb" do |m|
      assert_match "UsersController", m
      assert_match "def new", m
      assert_match "def create", m
      assert_match "@user = User.new", m
    end
  end

  test "it copies erb templates" do
    run_generator

    assert_file "app/views/identities/new.html.erb" do |m|
      assert_match "form_for @identity, url: identity_path", m
    end

    assert_file "app/views/sessions/new.html.erb" do |m|
      assert_match "form_for @identity, url: sessions_path", m
    end
  end

  test "it copies haml templates" do
    run_generator ["--haml"]

    assert_file "app/views/identities/new.html.haml" do |m|
      assert_match "form_for @identity, url: identity_path", m
    end

    assert_file "app/views/sessions/new.html.haml" do |m|
      assert_match "form_for @identity, url: sessions_path", m
    end
  end

  test "it add routes" do
    run_generator

    assert_file "config/routes.rb" do |m|
      assert_match "get 'sign_up', to: 'identities#new', as: :sign_up", m
      assert_match "get 'log_in', to: 'sessions#new', as: :log_in", m
      assert_match "delete 'log_out', to: 'sessions#destroy', as: :log_out", m

      assert_match "resource :identity, only: [:create, :new]", m
      assert_match "resource :sessions, only: [:create, :new]", m
    end
  end

  test "it generate migration" do
    Authentication::Generators::EmailGenerator.class_eval do
      def migration_name
        "create_#{resource_pluralize}.rb"
      end
    end

    run_generator

    assert_file "db/migrate/create_identities.rb" do |m|
      assert_match "create_table :identities", m
      assert_match "t.string :email", m
      assert_match "t.string :password_digest", m
    end

    assert_file "app/models/identity.rb" do |m|
      assert_match "class Identity < ActiveRecord::Base", m
      assert_match "has_secure_password validations: true", m
    end
  end

  test "it add helper methods to application controller" do
    run_generator

    assert_file "app/controllers/application_controller.rb" do |m|
      assert_match "helper_method :current_identity, :identity_signed_in?", m
      assert_match "def current_identity", m
      assert_match "def identity_signed_in?", m
      assert_match "def authenticate!", m
    end
  end

  test "it add warden gem to Gemfile" do
    run_generator

    assert_file "Gemfile" do |m|
      assert_match %(gem 'warden', '~> 1.2.0'), m
      assert_match %(gem 'bcrypt'), m
    end
  end

  test "it copy warden configuration" do
    run_generator

    assert_file "config/initializers/warden.rb" do |m|
      assert_match "manager.default_strategies :database_authentication", m
      assert_match "Warden::Manager.serialize_into_session(:identity)", m
      assert_match "Warden::Manager.serialize_from_session(:identity)", m
    end
  end

  test "it copy warden strategies" do
    run_generator

    assert_file "lib/strategies/database_authentication.rb" do |m|
      assert_match "def valid?", m
      assert_match "authenticate!", m
    end
  end
end
