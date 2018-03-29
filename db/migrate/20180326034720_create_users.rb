class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.text :avatar_data
      t.text :cover_photo_data

      t.timestamps
    end
  end
end
