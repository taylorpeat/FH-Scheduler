namespace :rmgames do
  desc "Remove orphaned game_teams"
  task :rm_game_teams => :environment do
    GameTeam.where([
      "game_id NOT IN (?)",
      Game.pluck("id")
    ]).destroy_all
  end
end
