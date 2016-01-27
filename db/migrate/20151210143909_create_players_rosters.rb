class CreatePlayersRosters < ActiveRecord::Migration
  def change
    create_table :players_rosters do |t|
      t.integer :player_id
      t.integer :roster_id
      t.timestamps
    end
  end
end
