class Game < ActiveRecord::Base
  has_many :game_teams
  has_many :teams, through: :game_teams
end