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
    table = player.table
    player.folded = true 
    player.last_action = "folded"
    player.save!

    table.doNext
    render :nothing => true
  end
  
  def check
    player = Player.find(params[:id])
    table = player.table
    player.last_action = "check"


    placedBets = 0
    highestBets = 0

    table.pots.each do |pot| 
      placedBets = placedBets + pot.getPlayerAmount(player.id)
      highestBets = highestBets + pot.highest_bet
    end

    call_amount = highestBets - placedBets

    # TODO all in?

  
    if player.pots.empty?
      pots = player.table.pots
    else
      pots = player.pots
    end
    pots.last.addAmount(player, call_amount)

    player.save!
    
    table.doNext

    render :nothing => true
  end
  
  def raise_bet
    player = Player.find(params[:id])
    table = player.table
    bet_amount = params[:amount]
    player.last_action = "raised " + bet_amount.to_s
    player.save

    # pots = player.pots
    pot = Pot.last
    
    pot.addAmount(player, bet_amount.to_i)
    
    table.doNext
    render :nothing => true
  end
  
  
end