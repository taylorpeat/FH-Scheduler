class Roster < ActiveRecord::Base
  belongs_to :user
  has_many :position_rosters
  has_many :positions, through: :position_rosters
  has_many :player_rosters
  has_many :players, through: :player_rosters

  attr_reader :roster_hash, :day

  def hash(roster_day)
    @day = roster_day
    initialize_hash
    assign_all_players
    roster_hash
  end

  private

    def initialize_hash
      @roster_hash = Hash.new([])
      self.positions.select { |pos| ![8,9].include?(pos.id) }.each do |position|
        roster_hash[position.id] += [""]
      end
    end

    def assign_all_players
      non_ir_player_size = self.players.count - self.positions.select { |pos| pos.id == 9 }.size
      assign_ir_players(non_ir_player_size)
      self.players.take(non_ir_player_size).sort.each do |player|
        assign_single_player(player)
      end
    end

    def assign_ir_players(non_ir_player_size)
      self.players.drop(non_ir_player_size).each do |player|
        assign_player_to_bench_or_ir(player.id, 9)
      end
    end

    def assign_single_player(player)
      no_player = Proc.new { |slot_val| slot_val == "" }
      no_game = Proc.new { |slot_val| self.players.find(slot_val).team.games.find_by(date: day) }
      unless assign_to_slot(player, &no_player)
        unless assign_to_slot(player, &no_game)
          assign_player_to_bench_or_ir(player.id, 8)
        end
      end
    end

    def assign_to_slot(player, &criteria)
      if assign_player_directly(player, &criteria)
        return true
      else
        if move_other_players(player.position_ids, player.position_ids, &criteria)
          assign_player_directly(player) { |slot_val| slot_val == "" }
          return true
        end
      end
      false
    end

    def assign_player_directly(player, &criteria)
      player.position_ids.each do |pos|
        roster_hash[pos].each_with_index do |slot_val, idx|
          if criteria.call(slot_val)
            if slot_val != ""
              assign_player_to_bench_or_ir(slot_val, 8)
            end
            implement_move(player.id, pos, idx)
            return true
          end
        end
      end
      false
    end

    def assign_player_to_bench_or_ir(player_id, pos)
      binding.pry
      roster_hash[pos] += [player_id]
    end

    def move_other_players(positions_to_check, positions_checked, &criteria)
      players_blocking_slots = roster_hash.select do |pos_id, player_ids|
        positions_to_check.include?(pos_id)
      end.values.flatten 
      binding.pry
      if move_player(players_blocking_slots, positions_checked, &criteria)
        binding.pry
        return true
      else
        binding.pry
        new_positions_checked = positions_to_check + positions_checked
        next_positions_to_check = players_blocking_slots.inject([]) do |all_player_ids, b_player_id|
          all_player_ids += self.players.find(b_player_id).position_ids
        end.uniq - new_positions_checked
        if next_positions_to_check.empty?
          binding.pry
          return false
        else
          binding.pry
          return true if move_other_players(next_positions_to_check, new_positions_checked, &criteria)
        end
      end
      false
    end

    def move_player(players_blocking_slots, positions_checked, &criteria)
      binding.pry
      players_blocking_slots.each do |player_id|
        self.players.find(player_id).position_ids.select { |pos| !positions_checked.include?(pos) }.each do |pos|
          roster_hash[pos].each_with_index do |slot_val, idx|
            binding.pry
            if criteria.call(slot_val)
              binding.pry
              if slot_val != ""
                binding.pry
                assign_player_to_bench_or_ir(slot_val, 8)
              end
              current_pos, current_idx = find_current_location(player_id)
              implement_move("", current_pos, current_idx)
              implement_move(player_id, pos, idx)
              return true
            end
          end
        end
      end
      false
    end

    def implement_move(player_id, pos, idx)
      binding.pry
      roster_hash[pos][idx] = player_id
    end

    def find_current_location(player_id)
      current_slot = roster_hash.select { |pos, player_ids| player_ids.include?(player_id) }.first
      current_pos = current_slot[0]
      current_idx = current_slot[1].find_index(player_id)
      [current_pos, current_idx]
    end

end