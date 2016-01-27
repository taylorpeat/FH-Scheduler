class CreatePlayersPositions < ActiveRecord::Migration
  def change
    create_table :players_positions do |t|
      t.integer :player_id
      t.integer :position_id
      t.timestamps
    end
  end
end
