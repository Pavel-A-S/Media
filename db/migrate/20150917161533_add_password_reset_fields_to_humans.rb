class AddPasswordResetFieldsToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :password_reset_token, :string
    add_column :humans, :password_reset_requested_at, :datetime
  end
end
