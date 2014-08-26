class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :href
      t.string :email
      t.datetime :emailed_at
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
