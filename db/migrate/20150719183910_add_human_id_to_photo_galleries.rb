class AddHumanIdToPhotoGalleries < ActiveRecord::Migration
  def change
    add_column :photo_galleries, :human_id, :integer
  end
end
