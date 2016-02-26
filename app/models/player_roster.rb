class PlayerRoster < ActiveRecord::Base
  belongs_to :player
  belongs_to :roster

  validates_uniqueness_of :player_id, scope: :roster_id
  
end