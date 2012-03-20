class PlayersController < ApplicationController
  
  def new
    @player = Player.new
    render 'new'
  end
  
  def signin
    @player = Player.new
    render 'signin'
  end

  def sign_ajax
    sign_in :player, Player.find(params[:player_id])
    render :json => {:player_id => current_player.id,
     :table_id => current_player.table_id}.to_json, :callback => params[:callback]
  end
  
end
