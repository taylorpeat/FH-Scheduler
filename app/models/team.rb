class Team < ActiveRecord::Base
  has_many :players
  has_many :game_teams
  has_many :games, through: :game_teams
end