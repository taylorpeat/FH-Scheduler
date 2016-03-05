class Roster < ActiveRecord::Base
  belongs_to :user
  has_many :position_rosters
  has_many :positions, through: :position_rosters
  has_many :player_rosters, dependent: :destroy
  has_many :players, through: :player_rosters

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :user

  include OrganizeRosterable

  def mem_players
    @mem_players ||= self.players.sort
  end

  def mem_position_ids(player_id)
    @mem_position_ids ||= Hash.new { |hash, player_id| hash[player_id] = mem_players.find(player_id).position_ids }
    @mem_position_ids[player_id]
  end

  def mem_team_game(team, mem_day)
    team_day = [team, mem_day]
    @mem_team_game ||= Hash.new { |hash, team_day| hash[team_day] = team_day[0].games.find_by(date: team_day[1]) }
    @mem_team_game[team_day]
  end

end