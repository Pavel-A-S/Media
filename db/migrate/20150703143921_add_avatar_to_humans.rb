class AddAvatarToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :avatar, :string
  end
end
