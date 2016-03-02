module ApplicationHelper
  include PlayerCheckable
  include TeamCheckable
  PLAYER_LIMIT = 49
  ROSTER_DEFAULTS = {C: 2, LW: 2, RW: 2, D: 4, G: 2, F: 0, U: 0, BN: 4, IR: 0}

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
    @roster_players.find(player_id) if player_id != ""
  end

  def find_position(pos_id)
    @roster_positions.find(pos_id)
  end

  def ir_slot_count
    @roster_positions.select { |pos| pos.id == 9 }.size
  end

  def highlight?(some_day, conflict_status)
    if conflict_status
      "<td class='conflict-col'>"
    else
      changed_date == some_day ? "<td class='current-day-col'>" : "<td>"
    end
  end

  def changed_date
    if @week_change == 0
      Date.today.beginning_of_day + @day_change.day
    else
      (changed_week + @day_change.day).beginning_of_day
    end
  end

  def beginning_of_week?
    changed_date == changed_week
  end

  def end_of_week?
    changed_date == changed_week.end_of_week + 1.week
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
    @roster.mem_position_ids(player).select {|pos_id| ![6,7,8,9].include?(pos_id) }.map {|pos_id| @positions.find(pos_id).name }.join(",")
  end

  def set_team_games
    day0 = changed_week.beginning_of_day
    weekly_team_games = {}
    @teams.each do |team|
      for day_num in 0..6
        day = day0 + day_num.day
        weekly_team_games[team.name] << team.games.find_by(date: day) ? :yes : :no
      end
    end
    weekly_team_games
  end

  def player_open_games(player)
    position_open_games[@roster.mem_position_ids(player)] & all_teams_games[player.team_id]
  end

  def set_open_games_per_position(dropped_player_id)
    pos_open_games = []
    for pos in 1..7
      pos_open_games << determine_open_positions(dropped_player_id)[pos]
    end
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
      combo.each do |pos|
        combo_open_games[combo] += pos_open_games[pos - 1]
      end
      combo_open_games[combo].sort!.uniq!
    end
    @position_open_games = combo_open_games
  end

  def position_open_games
    @position_open_games ||= set_open_games_per_position
  end

  def player_games(player)
    all_teams_games[player.team_id]
  end

  def active_players_each_day
    weeks_active_players = []
    day0 = changed_week.beginning_of_day
    for day_num in 0..6
      day = day0 + day_num.day
      weeks_active_players << @roster.mem_players.select { |player| @roster.mem_team_game(player.team, date: day) }
    end
    weeks_active_players
  end

  def players_to_check
    return @players_to_check if @players_to_check
    @players_to_check = Player.limit(400) - @roster.mem_players - [Player.find(0)]
  end

  def five_game_players
    return @five_game_players if @five_game_players
    @five_game_players = players_to_check.select { |player| player_open_games(player).size >= 5 }.slice(0..PLAYER_LIMIT)
  end

  def four_game_players
    return @four_game_players if @four_game_players
    @four_game_players = (players_to_check - @five_game_players)
                         .select { |player| player_open_games(player).size == 4 }.slice(0..PLAYER_LIMIT)
  end

  def three_game_players
    return @three_game_players if @three_game_players
    @three_game_players = (players_to_check - @five_game_players - @four_game_players)
                          .select { |player| player_open_games(player).size == 3 }.slice(0..PLAYER_LIMIT)
  end
  
  def two_game_players
    return @two_game_players if @two_game_players
    @two_game_players =  (players_to_check - @five_game_players - @four_game_players - @three_game_players)
                         .select { |player| player_open_games(player).size == 2 }.slice(0..PLAYER_LIMIT)
  end
  
  def one_game_players
    return @one_game_players if @one_game_players
    @one_game_players = (players_to_check - @five_game_players - @four_game_players - @three_game_players - @two_game_players)
                        .select { |player| player_open_games(player).size == 1 }.slice(0..PLAYER_LIMIT)
  end

  def droppable_players
    return @droppable_players if @droppable_players
    non_ir_players = @roster.mem_players.take(@roster.player_max - ir_slot_count).reverse
    @droppable_players = empty_slots? ? non_ir_players.unshift(Player.find(0)) : non_ir_players
  end

  def empty_slots?
    @roster.mem_players.size < (@roster.player_max - ir_slot_count) || @roster.mem_players.size == 0
  end

  def formatted_datetime(day)
    day.strftime('%a, %b %d')
  end

  def default_value(position, symbol)
    @roster.positions.empty? ? ROSTER_DEFAULTS[symbol] : @roster.positions.select { |pos| pos.id == position.id }.count
  end

end