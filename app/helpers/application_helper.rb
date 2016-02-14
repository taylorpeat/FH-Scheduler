module ApplicationHelper

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

end