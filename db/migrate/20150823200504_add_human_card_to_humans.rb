class AddHumanCardToHumans < ActiveRecord::Migration
  def change
    add_column :humans, :human_card, :string
  end
end
