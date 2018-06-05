class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, unique: true, index: true, null: false
      t.string :github_login, unique: true, index: true, null: false
      t.text :public_key, null: false
      t.string :fingerprint, unique: true, index: true, null: false
    end
  end
end
