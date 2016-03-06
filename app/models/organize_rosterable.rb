module OrganizeRosterable

  attr_reader :roster_hash, :day, :position_openings, :just_checking
  attr_accessor :conflicts


  def set_daily_rosters(roster_day, dropped_player_id = nil)
    daily_rosters = []
    for i in 0..13
      daily_rosters << hash(roster_day + i.day, dropped_player_id)
    end
    daily_rosters
  end


  private

    def hash(roster_day, dropped_player_id = nil)
      return roster_hash if @day == roster_day
      @day = roster_day
      @conflicts = []
      @just_checking = false
      @position_openings = []
      initialize_hash
      assign_all_players(dropped_player_id)
      update_position_openings unless dropped_player_id == nil
      roster_hash
    end

    def initialize_hash
      @roster_hash = Hash.new([])
      self.positions.each do |position|
        roster_hash[position.id] += [""]
      end
      roster_hash[8] = [] if roster_hash[8].empty?
      roster_hash
    end

    def assign_all_players(dropped_player_id)
      non_ir_player_size = self.player_max - self.positions.select { |pos| pos.id == 9 }.size
      assign_ir_players(non_ir_player_size)
      self.mem_players.take(non_ir_player_size).sort.each do |player|
        next if player.id == dropped_player_id
        assign_single_player(player)
      end
    end

    def update_position_openings
      @just_checking = true
      for position_id in 1..7
        next if conflicts.include?(position_id)
        if is_position_open?(position_id) || can_position_be_open?(position_id)
          @position_openings << position_id
        end
      end
      full_positions = [1,2,3,4,5,6,7] - position_openings
      roster_hash[:full] += full_positions unless full_positions.empty?
    end

    def is_position_open?(position_id)
      roster_hash[position_id].each do |slot_val|
        return true if (slot_val == "" || mem_team_game(mem_players.find(slot_val).team, day).nil?)
      end
      false
    end

    def can_position_be_open?(position_id)
      return true if move_other_players([position_id], [position_id])\
                     { |slot_val| slot_val == "" || !mem_team_game(mem_players.find(slot_val).team, day) }
      false
    end

    def assign_ir_players(non_ir_player_size)
      self.mem_players.drop(non_ir_player_size).each do |player|
        assign_player_to_bench_or_ir(player.id, 9)
      end
    end

    def assign_single_player(player)
      no_player = Proc.new { |slot_val| slot_val == "" }
      no_game = Proc.new { |slot_val| !mem_team_game(self.mem_players.find(slot_val).team, day) }
      unless assign_to_slot(player, &no_player)
        if no_game.call(player.id)
          assign_player_to_bench_or_ir(player.id, 8)
        else
          unless assign_to_slot(player, &no_game)
            assign_player_to_bench_or_ir(player.id, 8)
          end
        end
      end
    end

    def assign_to_slot(player, &criteria)
      if assign_player_directly(player, &criteria)
        return true
      else
        if move_other_players(mem_position_ids(player.id), mem_position_ids(player.id), &criteria)
          assign_player_directly(player) { |slot_val| slot_val == "" }
          return true
        end
      end
      false
    end

    def assign_player_directly(player, &criteria)
      mem_position_ids(player.id).each do |pos|
        roster_hash[pos].each_with_index do |slot_val, idx|
          if criteria.call(slot_val)
            if slot_val != ""
              bench_player_with_no_game(pos, player, &criteria)
              return true
            end
            implement_move(player.id, pos, idx)
            return true
          end
        end
      end
      false
    end

    def bench_player_with_no_game(pos, player, &criteria)
      roster_hash[pos].reverse.each_with_index do |slot_val, idx|
        if criteria.call(slot_val)
          implement_move(player.id, pos, roster_hash[pos].size - idx - 1)
          assign_player_to_bench_or_ir(slot_val, 8)
          return true
        end
      end
    end

    def assign_player_to_bench_or_ir(player_id, pos)
      add_or_replace_bench_or_ir(player_id, pos)
      if mem_team_game(self.mem_players.find(player_id).team, day)
        unless roster_hash[:conflicts].include?(player_id) || pos == 9
          roster_hash[:conflicts] += [player_id]
          update_conflict_positions(player_id)
          update_conflict_players
        end
      end
    end

    def add_or_replace_bench_or_ir(player_id, pos)
      if roster_hash[pos].include?("")
        roster_hash[pos].each_with_index do |slot_val, idx|
          if slot_val == ""
            roster_hash[pos][idx] = player_id
            break
          end
        end
      else
        roster_hash[pos] += [player_id]
      end
    end

    def update_conflict_positions(player_id)
      new_conflicts = mem_position_ids(player_id) - conflicts
      self.conflicts += new_conflicts
      new_conflicts.each do |pos|
        roster_hash[pos].each do |pos_player_id|
          update_conflict_positions(pos_player_id)
        end
      end
    end

    def update_conflict_players
      roster_hash[:conflicts] += conflicts.map { |pos| roster_hash[pos] }.flatten
      roster_hash[:conflicts].uniq!
    end

    def move_other_players(positions_to_check, positions_checked, &criteria)
      players_blocking_slots = roster_hash.select do |pos_id, player_ids|
        positions_to_check.include?(pos_id)
      end.values.flatten
      if move_player(players_blocking_slots, positions_checked, &criteria)        
        return true
      else
        return true if find_related_players_to_move(positions_to_check, positions_checked,
                       players_blocking_slots, &criteria)
      end
      false
    end

    def find_related_players_to_move(positions_to_check, positions_checked, players_blocking_slots, &criteria)
      new_positions_checked = positions_to_check + positions_checked
      next_positions_to_check = players_blocking_slots.inject([]) do |all_player_ids, b_player_id|
        all_player_ids += mem_position_ids(b_player_id)
      end.uniq - new_positions_checked
      if next_positions_to_check.empty?
        return false
      else
        if move_other_players(next_positions_to_check, new_positions_checked, &criteria)
          return true if just_checking == true
          move_other_players(positions_to_check, positions_checked) { |slot_val| slot_val == "" }
          return true
        end
      end
    end


    def move_player(players_blocking_slots, positions_checked, &criteria)
      players_blocking_slots.reverse.each do |player_id|
        mem_position_ids(player_id).select { |pos| !positions_checked.include?(pos) }.each do |pos|
          roster_hash[pos].reverse.each_with_index do |slot_val, idx|
            return true if ensure_open_slot_and_move_player(slot_val, idx, player_id, pos, &criteria)
          end
        end
      end
      false
    end

    def ensure_open_slot_and_move_player(slot_val, idx, player_id, pos, &criteria)
      if criteria.call(slot_val)
        return true if just_checking == true
        if slot_val != ""
          assign_player_to_bench_or_ir(slot_val, 8)
        end
        current_pos, current_idx = find_current_location(player_id)
        implement_move("", current_pos, current_idx)
        implement_move(player_id, pos, roster_hash[pos].size - idx - 1)
        return true
      end
    end
    
    def implement_move(player_id, pos, idx)
      roster_hash[pos][idx] = player_id
    end

    def find_current_location(player_id)
      current_slot = roster_hash.select { |pos, player_ids| player_ids.include?(player_id) }.first
      current_pos = current_slot[0]
      current_idx = current_slot[1].find_index(player_id)
      [current_pos, current_idx]
    end

end