class Roster < ActiveRecord::Base
  belongs_to :user
  has_many :position_rosters
  has_many :positions, through: :position_rosters
  has_many :player_rosters
  has_many :players, through: :player_rosters

  attr_accessor :roster_hash

  def hash(day)
    initialize_hash
    assign_players(day)
    roster_hash
  end

  private

    def initialize_hash
      @roster_hash = {}
      self.positions.each do |position|
        roster_hash[position.id] = [] if roster_hash[position.id].nil?
        assign_hash_position(position.id, 0)
      end
    end

    def assign_hash_position(position, i)
      roster_hash[position][i] ? assign_hash_position(position, i + 1) : self.roster_hash[position][i] = ""
    end

    def assign_players(day)
      self.players.each do |player|
        moves = assign_player_to_slot(player, day)
        binding.pry
        implement_moves(moves, player)
      end
    end



    def assign_player_to_open_slot(player, day, &criteria)
      check_open_slots
      if no?
        move_player(player.position_ids)
        check_open_slots
      end
      check_no_game_slots
      if no?
        move_player
        check_no_game_slots
      end
    end

    def move_player(related_positions, positions_checked)
      player2array = players_in_possible_positions(positions_checked)
      player2array.each do |player|
        player.positions.select { exclude positions checked }.each do |pos|
          if position_open?(pos)
            implement_move(move, player)
            return true
          end
        end
      end
      if no_moved?
        move_player((possible_positions + possible_positions_player2array))
        if moved?
          move_player(positions1)
        end
      end
    end

end