class CreateHumans < ActiveRecord::Migration
  def change
    create_table :humans do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
