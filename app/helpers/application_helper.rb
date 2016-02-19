module ApplicationHelper
  include PlayerCheckable
  include TeamCheckable

  def table_time(time)
    time.strftime("%m/%d")
  end

  def determine_forward(pos, game_date)
    if @forwards.select { |f| f.positions.include?(pos) && f.team.games.find_by(date: game_date) }.size > 0
      @forwards.select { |f| f.positions.include?(pos) && f.team.games.find_by(date: game_date) }.first
    elsif @forwards.select { |f| f.positions.include?(pos) }.size > 0
      @forwards.select { |f| f.positions.include?(pos) }.first
    end
  end

  def current_day
    Date.today.beginning_of_day
  end

  def find_player(player_id)
    @roster.players.find(player_id) if player_id != ""
  end

  def find_position(pos_id)
    @roster.positions.find(pos_id)
  end

  def ir_slot_count
    @roster.positions.select { |pos| pos == 9 }.size
  end

  def highlight?(some_day, conflict_status)
    if conflict_status
      "<td bgcolor = '#FFFF66'>"
    else
      changed_date == some_day ? "<td bgcolor = '#e5e5ff'>" : "<td>"
    end
  end

  def changed_date
    if @week_change == 0
      Date.today.beginning_of_day + @day_change.day
    else
      (changed_week + @day_change.day).beginning_of_day
    end
  end

  def changed_week
    Date.today.beginning_of_week + @week_change.week
  end

  def initial_time_offset
    if @week_change == 0
      (Date.today.beginning_of_week - Date.today).to_i
    else
      0
    end
  end

  def get_player_positions(player)
    player.positions.select {|pos| ![6,7,8,9].include?(pos.id) }.map {|pos| pos.name }.join(",")
  end

  def set_team_games
    day0 = changed_week.beginning_of_day
    weekly_team_games = {}
    Team.each do |team|
      for day_num in 0..6
        day = day0 + day_num.day
        weekly_team_games[team.name] << team.games.find_by(date: day) ? :yes : :no
      end
    end
    weekly_team_games
  end

  def player_open_games(player)
    @position_open_games[player.position_ids] & all_teams_games[player.team.id]
  end

  def set_open_games_per_position(dropped_player_id)
    pos_open_games = []
    for pos in 1..7
      pos_open_games << determine_open_positions(dropped_player_id)[pos]
    end
    combo_open_games = Hash.new([])
    pos_combos = [[1], [2], [3], [4], [1,2,3,4]] + [1,2,3,4].combination(3).to_a + [1,2,3,4].combination(2).to_a
    pos_combos.map! do |combo|
      if combo.include?(5)
        combo
      elsif combo.include?(4)
        combo + [7]
      else
        combo + [6,7]
      end
    end
    pos_combos.each do |combo|
      combo.each do |pos|
        combo_open_games[combo] += pos_open_games[pos - 1]
      end
      combo_open_games[combo].sort!.uniq!
    end
    @position_open_games = combo_open_games
  end

  def player_games(player)
    all_teams_games[player.team.id]
  end

  def active_players_each_day
    weeks_active_players = []
    day0 = changed_week.beginning_of_day
    for day_num in 0..6
      day = day0 + day_num.day
      weeks_active_players << @roster.players.select { |player| player.team.games.find_by(date: day) }
    end
    weeks_active_players
  end

  def players_to_check
    Player.all.limit(300).reject { |player| @roster.players.include?(player) }
  end

  def five_game_players
    players_to_check.select { |player| player_open_games(player).size >= 5 }
  end

  def four_game_players
    four_game_players = players_to_check.select { |player| player_open_games(player).size == 4 }
  end

  def three_game_players
    three_game_players = players_to_check.select { |player| player_open_games(player).size == 3 }
  end
  
  def two_game_players
    two_game_players =  players_to_check.select { |player| player_open_games(player).size == 2 }
  end
  
  def one_game_players
    one_game_players = players_to_check.select { |player| player_open_games(player).size == 1 }
  end

end