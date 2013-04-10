require 'test_helper'
require 'generators/authentication/omniauth/omniauth_generator'

describe Authentication::Generators::OmniauthGenerator do
  include GeneratorsTestHelper

  before do
    copy_routes
    copy_locales
    copy_gemfile
    copy_application_controller
    make_migrations_dir
  end

  it 'copies controllers templates for session' do
    run_generator

    assert_file 'app/controllers/sessions_controller.rb' do |m|
      assert_match 'SessionsController', m
      assert_match 'def create', m
      assert_match 'def destroy', m
    end
  end

  it 'add routes' do
    run_generator

    assert_file 'config/routes.rb' do |m|
      assert_match "get 'auth/:provider/callback' => 'sessions#create'", m
      assert_match "delete '/sessions/destroy' => 'sessions#destroy'", m
    end
  end

  it 'generate migration' do
    Authentication::Generators::OmniauthGenerator.class_eval do
      def migration_name
        "create_#{resource_pluralize}.rb"
      end
    end

    run_generator

    assert_file 'db/migrate/create_identities.rb' do |m|
      assert_match 'create_table :identities', m
      assert_match 't.string :provider', m
      assert_match 't.string :uid', m
      assert_match 't.string :name', m
      assert_match 't.string :email', m
    end

    assert_file 'app/models/identity.rb' do |m|
      assert_match 'class Identity < ActiveRecord::Base', m
      assert_match 'def find_identity(uid, provider)', m
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
      assert_match "gem \"omniauth\"", m
    end
  end

  it 'copy warden configuration' do
    run_generator

    assert_file 'config/initializers/warden.rb' do |m|
      assert_match 'manager.default_strategies :oauth_authentication', m
      assert_match 'Warden::Manager.serialize_into_session(:identity)', m
      assert_match 'Warden::Manager.serialize_from_session(:identity)', m
    end
  end

  it 'copy domain authentication configuration' do
    run_generator

    assert_file 'config/initializers/authentication_domain.rb'
  end

  it 'copy omniauth configuration' do
    run_generator

    assert_file 'config/initializers/omniauth.rb'
  end

  it 'copy warden strategies' do
    run_generator

    assert_file 'lib/strategies/oauth_authentication.rb' do |m|
      assert_match 'def valid?', m
      assert_match 'authenticate!', m
    end
  end
end
