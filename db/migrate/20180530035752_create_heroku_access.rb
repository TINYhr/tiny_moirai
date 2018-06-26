class CreateHerokuAccess < ActiveRecord::Migration[5.2]
  def change
    create_table :heroku_accesses do |t|
      t.references :user

      t.datetime :created_at, null: false
      t.boolean :active, default: nil
    end
  end
end
