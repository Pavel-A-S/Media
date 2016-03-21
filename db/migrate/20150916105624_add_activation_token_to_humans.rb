class AddActivationTokenToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :activation_token, :string
    add_column :humans, :activation_status, :string
    add_column :humans, :activated_at, :datetime
    add_column :humans, :last_login, :datetime
  end
end
