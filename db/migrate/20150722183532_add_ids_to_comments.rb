class AddIdsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :human_id, :integer
    add_column :comments, :photo_id, :integer
  end
end
