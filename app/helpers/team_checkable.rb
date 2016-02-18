module TeamCheckable

  def all_teams_games
    return @teams_weekly_games if @teams_weekly_games
    teams_weekly_games = Hash.new([])
    Team.all.each do |team|
      teams_weekly_games[team.id] += team_week_games(team)
    end
    teams_weekly_games
  end  

  def team_week_games(team)
    games_in_week = []
    day0 = changed_week.beginning_of_day
    for day_num in 0..6
      day = day0 + day_num.day
      games_in_week << day_num if team.games.find_by(date: day)
    end
    games_in_week
  end
end