class RostersController < ApplicationController

  before_action :set_roster, only: [:show, :edit, :update, :add_slot]

  def show
    @day_change = params[:day_change].to_i || 0
    @week_change = params[:week_change].to_i || 0
    @start_day = (Date.today.beginning_of_week + @week_change.week).beginning_of_day
    @daily_rosters = @roster.set_daily_rosters(@start_day)
    @players_to_drop = [params[:drop].to_i]
  end

  def new
    @roster = Roster.new
  end

  def create
    position_arr = {1 => params[:c].to_i, 2 => params[:lw].to_i, 3 => params[:rw].to_i, 4 => params[:d].to_i,
                 6 => params[:f].to_i, 7 => params[:u].to_i, 5 => params[:g].to_i, 8 => params[:bn].to_i,
                 9 => params[:ir].to_i}
    @roster = Roster.new
    @roster.user_id = current_user.id
    @roster.name = params[:team_name]
    @roster.player_max = position_arr.values.sum
    position_arr.each do |pos, num|
      num.to_i.times do
        roster_postition = @roster.position_rosters.new(position_id: pos)
      end
    end
    if @roster.save
      flash[:success] = "Roster created."
    else
      flash[:error] = "Roster could not be created."
    end
    redirect_to rosters_path
  end

  def index
    @rosters = current_user.rosters
  end

  def edit
    @roster = Roster.find(params[:id])
    @players = Player.all
  end

  def update
    if @roster.update(roster_params)
      flash[:success] = "Your roster has been updated."
    else
      flash[:notice] = "Your roster could not be updated."
    end
    redirect_to roster_path(@roster)
  end

  def add_slot
    binding.pry
    if @roster.update(player_max: @roster.player_max + 1)
       flash[:success] = "Your roster has been updated."
    else
       flash[:notice] = "Your roster could not be updated."
    end
    redirect_to edit_roster_path(@roster)
  end

  private
    def roster_params
      params.require(:roster).permit(player_ids: [])
    end

    def schedule_params
      params.require(:schedule).permit(:day)
    end

    def set_roster
      @roster = Roster.find(params[:id])
    end
end


