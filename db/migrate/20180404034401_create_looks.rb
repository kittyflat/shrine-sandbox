class CreateLooks < ActiveRecord::Migration[5.1]
  def change
    create_table :looks do |t|
      t.integer :user_id
      t.text :photo_data

      t.timestamps
    end
    add_index :looks, :user_id
  end
end
