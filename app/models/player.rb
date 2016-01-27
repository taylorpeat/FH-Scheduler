class Player < ActiveRecord::Base
  belongs_to :team
  has_many :player_positions
  has_many :positions, through: :player_positions
  has_many :player_rosters
  has_many :rosters, through: :player_rosters

  def all_position_ids
    positions.map { |pos| pos.id }
  end

  def name_for_select
    "#{name}: ##{ranking} - #{team.name.upcase}"
  end
end