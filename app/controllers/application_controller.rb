class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    @logged_in ||= !!current_user
  end

  def day_statuses(roster_hash, day)
    # determine which positions are available each day for a week, return hash
    #{today: [c,lw,rw,d], tomorrow: [c]}
  end

  def arrange_roster_ids(roster_ids)
    roster_ids.map!(&:to_i)
    if roster_ids.size == @roster.player_max
      ir_players = roster_ids.pop(@roster.positions.select {|pos| pos.id == 9 }.size)
    else
      ir_players = []
    end
    roster_ids.sort!.delete(0)
    ir_players.sort!.delete(0)
    { "player_ids" => (roster_ids + ir_players).map(&:to_s).uniq }
  end

  def add_remove_players(player_to_drop, player_to_add)
    roster_ids = @roster.player_ids
    roster_ids.delete(player_to_drop.to_i)
    ir_players = roster_ids.pop(@roster.positions.select {|pos| pos.id == 9 }.size)
    roster_ids += [player_to_add.to_i]
    roster_ids.sort!
    ir_players.sort!
    { "player_ids" => (roster_ids + ir_players).map(&:to_s) }
  end
end
