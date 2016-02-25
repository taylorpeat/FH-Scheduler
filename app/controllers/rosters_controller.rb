class RostersController < ApplicationController

  before_action :set_roster, only: [:show, :edit, :update, :add_slot, :destroy]

  def show
    @day_change = params[:day_change].to_i || 0
    @week_change = params[:week_change].to_i || 0
    @start_day = (Date.today.beginning_of_week + @week_change.week).beginning_of_day
    @daily_rosters = @roster.set_daily_rosters(@start_day)
    @player_to_drop = params[:drop].to_i unless params[:drop] == nil
    @players = Player.all
  end

  def new
    @roster = Roster.new
  end

  def create
    if params[:id]
      set_roster
      redirect_to set_roster_positions ? roster_path(@roster) : edit_roster_path(@roster, tab: "positions")
    else
      redirect_to set_roster_positions ? edit_roster_path(@roster) : new_roster_path
    end
  end

  def index
    @rosters = current_user.rosters
  end

  def edit
    @roster = Roster.find(params[:id])
    @players = Player.all - [Player.find(0)]
  end

  def update
    if params[:drop] && params[:add]
      params[:roster] = add_remove_players(params[:drop], params[:add])
    end
    if params[:roster]
      if @roster.update(arrange_roster_ids(roster_params["player_ids"]))
        @roster.players.clear
        @roster.update(arrange_roster_ids(roster_params["player_ids"]))
        flash[:success] = "Your roster has been updated."
      end
    else
      flash[:notice] = "Your roster could not be updated."
    end
    redirect_to roster_path(@roster, week_change: params[:week_change], day_change: params[:day_change])
  end

  def destroy
    name = @roster.name
    if @roster.delete
      flash[:success] = "#{name} was deleted."
    else
      flash[:error] = "#{name} could not be deleted."
    end
    redirect_to rosters_path
  end

  def add_slot
    if @roster.update(player_max: @roster.player_max + 1)
       flash[:success] = "Your roster has been updated."
    else
       flash[:notice] = "Your roster could not be updated."
    end
    redirect_to edit_roster_path(@roster)
  end

  def show_teams
    @teams = Team.all
    @week_change = params[:week_change].to_i || 0
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

    def set_roster_positions
      position_arr = {1 => params[:C].to_i, 2 => params[:LW].to_i, 3 => params[:RW].to_i, 4 => params[:D].to_i,
                 6 => params[:F].to_i, 7 => params[:U].to_i, 5 => params[:G].to_i, 8 => params[:BN].to_i,
                 9 => params[:IR].to_i}
      @roster = @roster || Roster.new
      @roster.user_id = @roster.user_id || current_user.id
      @roster.name = params[:team_name]
      @roster.player_max = position_arr.values.sum
      dropped_players = []
      if @roster.player_max < @roster.players.count
        dropped_players = @roster.players.delete(@roster.players.last(@roster.players.count - @roster.player_max))
      end
      @roster.position_rosters.clear if @roster.position_rosters
      position_arr.each do |pos, num|
        num.to_i.times do
          roster_postition = @roster.position_rosters.new(position_id: pos)
        end
      end
      if @roster.save
        unless dropped_players.empty?
          flash[:warning] = "#{dropped_players.map { |player| player.name }.join(", ")} #{"has".pluralize(dropped_players.size)} been removed from the roster due to the reduced positions."
        end
        return true
      else
        flash[:error] = "Roster could not be created."
        return false
      end
    end
end


