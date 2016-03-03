
module PlayerReportable
  PLAYER_LIMIT = 60

  def player_open_games(player)
    position_open_games[mem_position_ids(player)] & all_teams_games[player.team_id]
  end

  def position_open_games
    @position_open_games ||= set_open_games_per_position
  end

  def set_open_games_per_position(dropped_player_id)
    combo_open_games = Hash.new([])
    pos_combos = [[2, 3, 6, 7],
                  [1, 6, 7],
                  [1, 3, 6, 7],
                  [2, 6, 7],
                  [5],
                  [3, 6, 7],
                  [4, 7],
                  [1, 2, 3, 6, 7],
                  [1, 2, 6, 7],
                  [3, 4, 6, 7],
                  [2, 4, 6, 7],
                  [2, 4, 3, 6, 7],
                  [1, 4, 6, 7]]
    pos_combos.each do |combo|
      for day in 0..6
        combo_open_games[combo] += [day] unless (combo - @daily_rosters[day][:full]).empty?
      end
    end
    @position_open_games = combo_open_games
  end

  def all_teams_games
    return @teams_weekly_games if @teams_weekly_games
    teams_weekly_games = Hash.new([])
    Team.all.each do |team|
      teams_weekly_games[team.id] += team_week_games(team)
    end
    @teams_weekly_games = teams_weekly_games
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

  def players_to_check
    return @players_to_check if @players_to_check
    @players_to_check = Player.limit(500) - @roster.mem_players - [Player.find(0)]
  end

  def five_game_players
    return @five_game_players if @five_game_players
    @five_game_players = players_to_check.select { |player| player_open_games(player).size >= 5 }.slice(0..PLAYER_LIMIT)
  end

  def four_game_players
    return @four_game_players if @four_game_players
    @four_game_players = (players_to_check - five_game_players)
                         .select { |player| player_open_games(player).size == 4 }.slice(0..PLAYER_LIMIT)
  end

  def three_game_players
    return @three_game_players if @three_game_players
    @three_game_players = (players_to_check - five_game_players - four_game_players)
                          .select { |player| player_open_games(player).size == 3 }.slice(0..PLAYER_LIMIT)
  end
  
  def two_game_players
    return @two_game_players if @two_game_players
    @two_game_players =  (players_to_check - five_game_players - four_game_players - three_game_players)
                         .select { |player| player_open_games(player).size == 2 }.slice(0..PLAYER_LIMIT)
  end
  
  def one_game_players
    return @one_game_players if @one_game_players
    @one_game_players = (players_to_check - five_game_players - four_game_players - three_game_players - two_game_players)
                        .select { |player| player_open_games(player).size == 1 }.slice(0..PLAYER_LIMIT)
  end

end
