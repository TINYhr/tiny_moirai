class CreateHerokuAccess < ActiveRecord::Migration[5.2]
  def change
    create_table :heroku_accesses do |t|
      t.references :user

      t.datetime :created_at, null: false
      t.string :fingerprint, unique: true, index: true, null: false
    end
  end
end