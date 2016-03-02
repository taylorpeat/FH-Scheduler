class RostersController < ApplicationController #didn't render in controllers?

  before_action :require_login, except: [:show_teams]
  before_action :set_roster, only: [:show, :edit, :update, :destroy]
  before_action :require_current_user_roster, only: [:edit, :show, :update, :destroy]

  def show
    @day_change = params[:day_change].to_i || 0
    @week_change = params[:week_change].to_i || 0
    @start_day = (Date.today.beginning_of_week + @week_change.week).beginning_of_day
    @daily_rosters = @roster.set_daily_rosters(@start_day)
    @roster_players = @roster.players
    @roster_positions = @roster.positions
    @positions = Position.all
    @player_to_drop = params[:drop].to_i unless params[:drop] == nil
    @teams = Team.all
    if params[:drop]
      respond_to do |format|
        format.html
        format.js { render 'report.js.erb' }
      end
    else
      respond_to :html, :js
    end
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
    @players = Player.limit(1001) - [Player.find(0)]
    @tab = params[:tab]
    respond_to :js, :html
  end

  def update
    if params[:drop] && params[:add]
      params[:roster] = add_remove_players(params[:drop], params[:add])
    end
    players_added = params[:roster]["player_ids"]
    duplicates = players_added.select { |id| players_added.count(id) > 1 && id != "" }.uniq
    if params[:roster]
      if @roster.update(arrange_roster_ids(roster_params["player_ids"]))
        @roster.players.clear
        @roster.update(arrange_roster_ids(roster_params["player_ids"]))
        if duplicates.empty? 
          flash[:success] = "Your roster has been updated."
        else
          flash[:warning] = "#{duplicates.map {|x| Player.find(x.to_i).name }.join(", ")} #{'was'.pluralize(duplicates.size)} selected multiple times. #{'Duplicate'.pluralize(duplicates.size)} #{'has'.pluralize(duplicates.size)} been removed." unless duplicates.empty?
          redirect_to edit_roster_path(@roster) and return
        end
      else
        flash[:success] = "Your roster could not be updated."
      end
    else
      flash[:success] = "Your roster could not be updated."
    end
    redirect_to roster_path(@roster, week_change: params[:week_change], day_change: params[:day_change])
  end

  def destroy
    name = @roster.name
    if @roster.delete
      flash[:success] = "#{name} was deleted."
    else
      flash[:danger] = "#{name} could not be deleted."
    end
    redirect_to rosters_path
  end

  def show_teams
    @teams = Team.all
    @week_change = params[:week_change].to_i || 0
    @start_day = (Date.today.beginning_of_week + @week_change.week).beginning_of_day
    if params[:by_game] == "true"
      @teams = @teams.sort_by { |team| team.games.select { |game| game.date.between?(@start_day, @start_day + 6.days) }.count }.reverse
    end
    respond_to :js, :html
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
        flash[:danger] = "Roster could not be created."
        return false
      end
    end
end


