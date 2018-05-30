class CreateExportTrackings < ActiveRecord::Migration[5.2]
  def change
    create_table :exports_production_db do |t|
      t.references :user

      t.string :fingerprint, unique: true, index: true, null: false
      t.string :status, default: 'requested'
      t.boolean :is_notify, default: true, null: false

      t.datetime :requested_at, null: false
      t.datetime :notified_at, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
