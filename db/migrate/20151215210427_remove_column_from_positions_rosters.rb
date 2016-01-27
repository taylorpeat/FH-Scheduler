class RemoveColumnFromPositionsRosters < ActiveRecord::Migration
  def change
    remove_column :positions_rosters, :player_id
  end
end
