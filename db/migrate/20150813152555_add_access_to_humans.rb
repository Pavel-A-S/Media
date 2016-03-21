class AddAccessToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :access, :string
  end
end
