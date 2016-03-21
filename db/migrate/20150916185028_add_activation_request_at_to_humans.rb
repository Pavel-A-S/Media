class AddActivationRequestAtToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :activation_request_at, :datetime
  end
end
