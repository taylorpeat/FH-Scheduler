class RenameGamesTeams < ActiveRecord::Migration
  def change
    rename_table :games_teams, :game_teams
    rename_table :players_positions, :player_positions
    rename_table :players_rosters, :player_rosters
    rename_table :positions_rosters, :position_rosters
  end
end
