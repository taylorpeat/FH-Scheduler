class CreateRosterSlots < ActiveRecord::Migration
  def change
    create_table :roster_slots do |t|
      t.integer :roster_id
      t.integer :player_id
      t.integer :position_id
    end
  end
end
