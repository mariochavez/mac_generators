module GeneratorsTestHelper
  def self.included(base)
    base.class_eval do
      destination File.join(Rails.root, "tmp")
      setup :prepare_destination

      begin
        base.tests Rails::Generators.const_get(base.name.sub(/Test$/, ''))
      rescue
      end
    end
  end

  def copy_routes
    routes = File.expand_path("../../fixtures/routes.rb", __FILE__)
    destination = File.join(destination_root, "config")

    copy_file routes, destination
  end

  def copy_gemfile
    gemfile = File.expand_path("../../fixtures/Gemfile", __FILE__)

    copy_file gemfile, destination_root
  end

  def copy_application_controller
    controller = File.expand_path("../../fixtures/application_controller.rb", __FILE__)
    destination = File.join(destination_root, 'app', 'controllers')

    copy_file controller, destination
  end

  def copy_locales
    controller = File.expand_path("../../fixtures/en.yml", __FILE__)
    destination = File.join(destination_root, 'config', 'locales')

    copy_file controller, destination
  end

  def copy_file(file, destination)
    FileUtils.mkdir_p(destination)
    FileUtils.cp file, destination
  end

  def make_migrations_dir
    destination = File.join(destination_root, 'db', 'migrate')

    FileUtils.mkdir_p(destination)
  end
end
