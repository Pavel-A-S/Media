class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :human_id
      t.integer :photo_gallery_id
      t.timestamps null: false
    end
  end
end
