class TablesController < ApplicationController

  include GameLogic

  def index
    @tables = Table.all
    render 'index'
  end
  def show
    @table = Table.find(params[:id])
  end
  
  def fold
    player = Player.find(params[:id])
    player.folded = true 
    player.last_action = "folded"
    player.save!

    @table.doNext
    render :nothing => true
  end
  
  def check
    player = Player.find(params[:id])
    player.last_action = "check"
    player.save!
    
    @table = player.table    
    @table.player_turn = ((player.id + 1) % @table.players.count)
    @table.save!
    
    @table.doNext
    render :nothing => true
  end
  
  def raise_bet
    player = Player.find(params[:id])
    table = player.table
    bet_amount = params[:amount]
    player.last_action = "raised " + bet_amount.to_s
    player.amount = player.amount - bet_amount.to_i
    player.save!
    
    pots = player.pots
    pot = Pot.new
    min_players = 10
    pots.each do |p|
      if p.players.count < min_players
          pot = p
      end
    end
    
    pot.amount = pot.amount + bet_amount.to_i
    pot.highest_bet += bet_amount.to_i
    pot.save!
    
    @table.doNext
    render :nothing => true
  end
  
  
end