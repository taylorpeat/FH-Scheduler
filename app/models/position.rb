class Position < ActiveRecord::Base
  has_many :player_positions
  has_many :players, through: :player_positions
  has_many :position_rosters
  has_many :positions, through: :position_rosters
end