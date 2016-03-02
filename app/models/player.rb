class Player < ActiveRecord::Base
  belongs_to :team
  has_many :player_positions
  has_many :positions, through: :player_positions
  has_many :player_rosters, dependent: :destroy
  has_many :rosters, through: :player_rosters

  def all_position_ids
    positions.map { |pos| pos.id }
  end

  def name_for_select
    "#{name}: ##{ranking} - #{team.name.upcase}"
  end
  
  def mem_position_ids
    @mem_position_ids ||= self.position_ids
  end

  def mem_team_game(day)
    @mem_team_games ||= Hash.new { |hash, day| hash[day] = self.team.games.find_by(date: day) }
    @mem_team_games[day]
  end
end