class AddPublicKeyColumnToHerokuAccesses < ActiveRecord::Migration[5.2]
  def change
    add_column :heroku_accesses, :public_key, :text
    add_column :heroku_accesses, :public_key_title, :string
  end
end
