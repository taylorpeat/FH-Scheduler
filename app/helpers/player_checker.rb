module PlayerChecker

  def determine_open_positions(dropped_player_id)
    @daily_rosters.each_with_index do |roster, idx|
      @open_positions[idx] << day_open_positions(roster, dropped_player_id)
    end
  end

  def check_hash(roster, dropped_player_id)
    day_open_positions = {}
    (1..7).each do |pos_id|
      day_open_positions[pos_id] = pos_roster_openings(roster, dropped_player_id, pos_id)
    end
    day_open_positions
  end

  def day_roster_openings(roster, dropped_player_id, pos_id, day)
    active_players = @roster.players.select { |player| player.team.games.find_by(date: day) }
    pos_connections = determine_roster_connections(active_players, day)
    check_for_openings(pos_connections, roster, dropped_player_id, active_players)
  end

  def determine_roster_connections(day)
    pos_connections = []
    (1..7).each do |pos_id|
      unless pos_connections.flatten.include?(pos_id)
        pos_connections << find_associated_players(active_players, pos_id, [pos_id])
      end
    end
    pos_connections
  end

  def find_associated_players(active_players, pos_id, prev_connected_positions)
    connected_positions = active_players.select { |a_player| a_player.position_ids.include?(pos_id) }
                         .map { |a_player| a_player.position_ids }.flatten.uniq
    new_connected_positions = connected_positions - prev_connected_positions
    new_connected_positions.each do |new_pos_id|
      additional_positions = find_associated_players(active_players, new_pos_id, prev_connected_positions + new_connected_positions)
    end
    new_connected_positions + additional_positions
  end

  def check_for_openings(pos_connections, roster, dropped_player_id, active_players)
    roster.each do |pos_id|
      unless open_positions.include?(pos_id)
        pos.each do |player_id|
          unless active_players.include?(player_id) && player_id != dropped_player_id
            open_positions << pos_connections.select { |pos_connection| pos_connection.include?(pos_id) }.flatten
            break
          end
        end
      end
    end
    open_positions.uniq
  end

  # everyday, find whether positions are available.
  #  to do this find connections, then check each spot individually
  # put them into arrays
  # make a hash with key being player pos array and value being array of open days
  # combine with team arrays to determine player availability