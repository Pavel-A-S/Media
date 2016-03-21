class AddTypeToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :source_type, :string
  end
end
