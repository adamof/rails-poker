class PlayersController < ApplicationController
  
  def new
    @player = Player.new
    render 'new'
  end
  
  def signin
    @player = Player.new
    render 'signin'
  end
  
end
