class Create<%= resource_pluralize.capitalize %> < ActiveRecord::Migration
  def change
    create_table :<%= resource_pluralize %> do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
