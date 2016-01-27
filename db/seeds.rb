require 'csv'

Position.delete_all

positions = %W(C LW RW D G F U BN IR)

positions.each_with_index do |position, idx|
  Position.create(id: idx + 1, name: position)
end


Game.delete_all

CSV.foreach('db/game_dates.csv') do |row|
  Game.create(id: row[0], date: row[1])
end


CSV.foreach('db/players.csv', headers: true) do |row|
  player = Player.where(id: row["id"]).first_or_create
  player.update(team_id: row["team_id"], ranking: row["ranking"], name: row["name"])
end


GamesTeam.delete_all

CSV.foreach('db/games_teams.csv') do |row|
  GamesTeam.create(game_id: row[0], team_id: row[1])
end


Team.delete_all

CSV.foreach('db/teams.csv') do |row|
  Team.create(id: row[0], name: row[1])
end


PlayersPosition.delete_all

CSV.foreach('db/players_positions.csv') do |row|
  PlayersPosition.create(player_id: row[0], position_id: row[1])
end

