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
  
  def startHand
    @table = Table.find(params[:id])
    @table.dealDeck
    @table.dealToPlayers
    @table.players.each do |p|
      p.folded = false
      p.last_action = nil
      p.save!
    end
    @table.determineStartingPlayer("first")
    @table.takeBlinds
    player = @table.players[@table.player_turn]
    GameLogic.possibleActions(@table).publish
  end
  
  def nextPlayerTurn
    @table.incrementPlayerTurn
    GameLogic.poassibleActions(@table).publish
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
    player.amount = player.amount - bet_amount.to_i
    player.save!
    
    pot = player.table.pots.first
    # pots = player.pots
    # pot = Pot.new
    # max_players = -1
    # pots.each do |p|
    #   if p.players.size > max_players
    #     pot = p
    #   end
    # end
    
    pot.amount = pot.amount + bet_amount.to_i
    pot.save!
    
    @table = player.table
    @table.player_turn = ((player.id + 1) % @table.players.count)
    @table.save!
    render :nothing => true
  end
  
  def deal
    @table = Table.find(params[:id])
    players = @table.players
    
    players.each do |p|
      p.card_1 = "Card " + rand(52).to_s
      p.card_2 = "Card " + rand(52).to_s
      p.save!
    end
    
    render :nothing => true
  end
  
end