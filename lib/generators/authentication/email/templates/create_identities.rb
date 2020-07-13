class Create<%= resource_pluralize.capitalize %> < ActiveRecord::Migration[6.0]
  def change
    create_table :<%= resource_pluralize %> do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
