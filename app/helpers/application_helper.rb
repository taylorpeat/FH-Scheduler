module ApplicationHelper
  include PlayerReportable
  
  ROSTER_DEFAULTS = {C: 2, LW: 2, RW: 2, D: 4, G: 2, F: 0, U: 0, BN: 4, IR: 0}
  POSITION_IDS = {1 => "C", 2 => "LW", 3 => "RW", 4 => "D", 5 => "G", 6 => nil, 7 => nil, 8 => nil, 9 => nil}

  def table_time(time)
    time.strftime("%m/%d")
  end

  def current_day
    Date.today.beginning_of_day
  end

  def find_player(player_id)
    @roster.mem_players.find(player_id) if player_id != ""
  end

  def ir_slot_count
    @roster.positions.select { |pos| pos.id == 9 }.size
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

  def get_roster_player_positions(player_id)
    @roster.mem_position_ids(player_id).map {|pos_id| POSITION_IDS[pos_id] }.compact.join(",")
  end

  def get_player_positions(player)
    mem_position_ids(player).map {|pos_id| POSITION_IDS[pos_id] }.compact.join(",")
  end

  def mem_position_ids(player)
    @mem_position_ids ||= Hash.new { |hash, player| hash[player] = player.position_ids }
    @mem_position_ids[player]
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