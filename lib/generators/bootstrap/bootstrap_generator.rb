class BootstrapGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  argument :resource_name, type: :string, default: "application"
  class_option :haml, type: :boolean, default: false, description: "Generate haml templates"

  def add_gems
    gem "bootstrap-sass"
  end

  def create_scss_files
    copy_file "_variables.css.scss", "app/assets/stylesheets/#{resource_name}/_variables.css.scss"
    copy_file "_application.css.scss", "app/assets/stylesheets/#{resource_name}/_#{resource_name}.css.scss"
  end

  def create_scss_manifest
    template "application.scss", "app/assets/stylesheets/#{resource_name}.scss"
  end

  def create_coffee_manifest
    template "application.js", "app/assets/javascripts/#{resource_name}.js"
  end

  def create_layout
    if options[:haml]
      template "application.html.haml", "app/views/layouts/#{resource_name}.html.haml"
    else
      template "application.html.erb", "app/views/layouts/#{resource_name}.html.erb"
    end
  end

  private

  def application_name
    Rails.application.class.name.split("::").first
  end
end
