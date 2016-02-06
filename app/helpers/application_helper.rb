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

  def ir_slot_count
    @roster.positions.select { |pos| pos == 9 }.size
  end
end