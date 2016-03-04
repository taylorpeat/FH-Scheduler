class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_login
    unless logged_in?
      flash[:danger] = "You must be logged in to access this page."
      redirect_to root_path
    end
  end

  def require_current_user
    if current_user != User.find(params[:id])
      flash[:danger] = "You do not have access to this page."
      redirect_to root_path
    end
  end

  def require_current_user_roster
    unless current_user.rosters.include?(@roster)
      flash[:danger] = "You do not have access to this roster."
      if logged_in?
        redirect_to rosters_path and return
      else
        redirect_to root_path and return
      end
    end
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
    num_empty_slots = @roster.player_max - roster_ids.size
    num_ir_slots = @roster.positions.select {|pos| pos.id == 9 }.size
    if num_empty_slots < num_ir_slots
      ir_players = roster_ids.pop(num_ir_slots - num_empty_slots)
    else
      ir_players = []
    end
    sort_and_return_roster_params(roster_ids, ir_players)
  end

  def add_remove_players(player_to_drop, player_to_add)
    roster_ids = @roster.player_ids
    roster_ids.delete(player_to_drop.to_i)
    ir_players = roster_ids.pop(@roster.positions.select {|pos| pos.id == 9 }.size)
    roster_ids += [player_to_add.to_i]
    sort_and_return_roster_params(roster_ids, ir_players)
  end

  def sort_and_return_roster_params(roster_ids, ir_players)
    roster_ids.sort!.delete(0)
    ir_players.sort!.delete(0)
    { "player_ids" => (roster_ids + ir_players).map(&:to_s).uniq } 
  end
end
