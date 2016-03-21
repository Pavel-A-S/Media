class CreatePhotoGalleries < ActiveRecord::Migration
  def change
    create_table :photo_galleries do |t|
      t.string :description
      t.string :cover

      t.timestamps null: false
    end
  end
end
