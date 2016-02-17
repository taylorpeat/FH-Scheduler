module PlayerCheckable

  def determine_open_positions(dropped_player_id)
    open_positions = Hash.new([])
    day0 = changed_week.beginning_of_day
    for day_num in 0..6
      day = day0 + day_num.day
      open_positions[day_num] += day_roster_openings(@daily_rosters[day_num], dropped_player_id, day)
    end
    binding.pry
    position_weekly_openings = set_position_opening_hash(open_positions)
  end

  def day_roster_openings(roster, dropped_player_id, day)
    active_players = @roster.players.select { |player| player.team.games.find_by(date: day) }
    pos_connections = connections_between_positions(active_players, day)
    positions_open = check_for_open_roster_slots(pos_connections, roster, dropped_player_id, active_players)
    binding.pry
    useable_positions = pos_connections.select { |conn| positions_open.any? { |open_pos| conn.include?(open_pos) } }.flatten.uniq
  end

  def connections_between_positions(active_players, day)
    pos_connections = []
    (1..7).each do |pos_id|
      unless pos_connections.flatten.include?(pos_id)
        pos_connections << positions_of_associated_players(active_players, pos_id, [pos_id])
      end
    end
    binding.pry
    pos_connections
  end

  def positions_of_associated_players(active_players, pos_id, prev_connected_positions)
    additional_positions = []
    connected_positions = active_players.select { |a_player| a_player.position_ids.include?(pos_id) }
                         .map { |a_player| a_player.position_ids }
                         .select { |pos_id| @roster.position_ids.include?(pos_id) }.flatten.uniq
    new_connected_positions = connected_positions - prev_connected_positions
    new_connected_positions.each do |new_pos_id|
      additional_positions = positions_of_associated_players(active_players, new_pos_id,
                                                     prev_connected_positions + new_connected_positions)
    end
    binding.pry
    new_connected_positions + additional_positions
  end

  def check_for_open_roster_slots(pos_connections, roster, dropped_player_id, active_players)
    open_positions = []
    roster.select { |pos_id, players| ![8,9].include?(pos_id) }.each do |pos_id, players|
      unless open_positions.include?(pos_id)
        if players.any? { |player_id| !active_players.include?(@roster.players.find(player_id)) ||
                                   player_id == dropped_player_id }
          open_positions << pos_id
          break
        end
      end
    end
    binding.pry
    open_positions
  end

  def set_position_opening_hash(open_positions)
    position_weekly_openings = Hash.new([])
    for day_num in 0..6
      for pos_id in 1..7
        position_weekly_openings[pos_id] += [day_num] if open_positions[day_num].include?(pos_id)
      end
    end
    binding.pry
    position_weekly_openings
  end

end