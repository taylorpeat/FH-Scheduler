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

  def set_daily_rosters(day)
    daily_rosters = []
    for i in 0..13
      daily_rosters << @roster.hash(day + i.day)
    end
    daily_rosters
  end
end
