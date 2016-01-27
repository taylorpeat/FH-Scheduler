class RenameRosterSlotsToPositionsRosters < ActiveRecord::Migration
  def change
    rename_table :roster_slots, :positions_rosters
  end
end
