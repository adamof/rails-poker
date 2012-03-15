class TablesController < ApplicationController
  def index
    @tables = Table.all
    render 'index'
  end
  def show
    @table = Table.find(params[:id])
  end
  def bet
    
  end
  
  def fold
    player = Player.find(params[:id])
    player.folded = true 
    player.last_action = "folded"
    player.save!
    
    @table = player.table
    @table.player_turn = ((player.id + 1) % @table.players.count)
    @table.save!

    render :nothing => true
  end
  
  def check
    player = Player.find(params[:id])
    player.last_action = "check"
    player.save!
    
    @table = player.table    
    @table.player_turn = ((player.id + 1) % @table.players.count)
    @table.save!
    render :nothing => true
  end
  
  def raise_bet
    player = Player.find(params[:id])
    bet_amount = params[:amount]
    player.last_action = "raised " + bet_amount
    player.money = player.money - bet_amount.to_i
    player.save!
    
    pots = player.pots
    pot = Pot.new
    max_players = -1
    pots.each do |p|
      if p.players.size > max_players
        pot = p
      end
    end
    
    pot.amount = pot.amount + bet_amount.to_i
    pot.save!
    
    @table = player.table
    @table.player_turn = ((player.id + 1) % @table.players.count)
    @table.save!
    render :nothing => true
  end
  
end