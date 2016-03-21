class AddPasswordDigestToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :password_digest, :string
  end
end
