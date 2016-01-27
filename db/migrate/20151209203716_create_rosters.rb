class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.string :name
      t.integer :player_max
      t.integer :user_id
      t.string :slug
      t.timestamps
    end
  end
end
