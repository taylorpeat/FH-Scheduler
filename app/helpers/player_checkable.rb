module PlayerCheckable

  def determine_open_positions(dropped_player_id)
    @weekly_open_positions if @weekly_open_positions
    open_positions = Hash.new([])
    for day_num in 0..6
      open_positions[day_num] += day_roster_openings(@daily_rosters[day_num], dropped_player_id, day_num)
    end
    @weekly_position_openings = set_position_open_days_hash(open_positions)
  end

  def day_roster_openings(roster, dropped_player_id, day_num)
    active_players = active_players_each_day[day_num]
    pos_connections = connections_between_positions(active_players)
    positions_open = check_for_open_roster_slots(roster, dropped_player_id, active_players)
    useable_positions = pos_connections.select { |conn| positions_open
                        .any? { |open_pos| conn.include?(open_pos) } }.flatten.uniq
  end

  def connections_between_positions(active_players)
    pos_connections = []
    (1..7).select { |pos_id| @roster.position_ids.include?(pos_id) }.each do |pos_id|
      unless pos_connections.flatten.include?(pos_id)
        pos_connections << [pos_id] + positions_of_associated_players(active_players, pos_id, [pos_id])
      end
    end
    pos_connections
  end

  def positions_of_associated_players(active_players, pos_id, prev_connected_positions)
    additional_positions = []
    connected_positions = active_players.select { |a_player| a_player.position_ids.include?(pos_id) }
                         .map { |a_player| a_player.position_ids }.flatten
                         .select { |pos_id| @roster.position_ids.include?(pos_id) }.uniq
    new_connected_positions = connected_positions - prev_connected_positions
    new_connected_positions.each do |new_pos_id|
      additional_positions = positions_of_associated_players(active_players, new_pos_id,
                                                     prev_connected_positions + new_connected_positions)
    end
    new_connected_positions + additional_positions
  end

  def check_for_open_roster_slots(roster, dropped_player_id, active_players)
    open_positions = []
    roster.select { |pos_id, players| ![8,9].include?(pos_id) }.each do |pos_id, players|
      if players.any? { |player_id| !active_players.include?(@roster.players.find(player_id)) ||
                                    player_id == dropped_player_id &&
                                    !active_players.select { |player| roster[8].include?(player_id) } &&
                                    !active_players.select { |player| roster[8].include?(player_id) }
                                    .position_ids.include?(pos_id) }
        open_positions << pos_id
      end
    end
    open_positions
  end

  def set_position_open_days_hash(open_positions)
    position_weekly_openings = Hash.new([])
    for pos_id in 1..7
      for day_num in 0..6
        position_weekly_openings[pos_id] += [day_num] if open_positions[day_num].include?(pos_id)
      end
    end
    position_weekly_openings
  end

end