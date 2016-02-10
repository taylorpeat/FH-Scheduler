module ApplicationHelper

  def table_time(time)
    time = time.strftime("%m/%d")
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
      (Date.today.beginning_of_day + @day_change.day).beginning_of_day
    else
      (changed_week + @day_change.day).beginning_of_day
    end
  end

  def changed_week
    (Date.today.beginning_of_week + @week_change.week).beginning_of_day
  end

end