class Create<%= resource_pluralize.capitalize %> < ActiveRecord::Migration
  def change
    create_table :<%= resource_pluralize %> do |t|
      t.string :email
      t.string :password_hash
      t.string :password_salt

      t.timestamps
    end
  end
end
