module GameLogic

  # don't allow it to use the same cards (remove doubles)
  PokerHand.allow_duplicates = false

  # determine the winner
  def determineWinner(table)
    
    activePlayers = 0
    table.players.each do |player|
      if player.folded == false # || player.left_game_at != nil
        activePlayers += 1
      end
    end
    if activePlayers == 1 and table.pots.count == 1
      winner = table.players.where("folded='false'").first
      winner.amount += table.pots.first.amount
      return {winner.id.to_s => table.pots.first.amount}
    end



    # arrays for results
    playerHands = {}
    results = {}
    
    # get the hands
    table.players.each do |player|
      playerCards = table.cards_on_table
      playerCards << player.card_1
      playerCards << player.card_2

      playerHands[player.id] = PokerHand.new(playerCards)
    end
    
    potProfits = []

    table.pots.each do |pot|
      potWinners = {}
      winners = 0
      winningHand = PokerHand.new

      # find the winning hand
      pot.player_amounts.each do |player_id, amount|
        winningHand = (winningHand < playerHands[player_id]) ? playerHands[player_id] : winningHand
        p winningHand.rank
      end

      # find out how many people share the pot
      pot.player_amounts.each do |player_id, amount|
        if winningHand == playerHands[player_id]
          winners += 1
          potWinners[player_id]=0
        end

      end

      # set the corect profit
      potWinners.each do |winner_id, amount|
        potWinners[winner_id] = pot.amount/winners
      end
      potProfits << potWinners
    end

    potProfits.each do |pot|
      pot.each do |potWinner_id, amount|
        if results.key? potWinner_id
          results[potWinner_id] += amount
        else
          results[potWinner_id] = amount
        end
      end
    end

    biggestWinner = 0
    biggestProfit = 0

    results.each do |key, value|
      player = Player.find(key)
      player.amount += value.to_i
      if value.to_i > biggestProfit
        biggestProfit = value.to_i
        biggestWinner = key
      end
      player.save!
    end
    Juggernaut.publish("#{table.id}", results.to_json)
    Juggernaut.publish("#{table.id}", "The winning hand was: " +  playerHands[biggestWinner].rank + " Its player was " + Player.find(biggestWinner).email)
    Pot.delete_all

    p "-------------||||||||||||||--------" + results.to_s + "---------"
    return results
  end
  
  def dealCard(cardsInDeck)
  	cardIndex = rand(cardsInDeck.length)
  	card = cardsInDeck[cardIndex]
  	return card
  end
  
  def possibleActions(player)

    table = player.table
    actions = Hash.new

    # see if it's the player's turn
    if table.players[table.player_turn] != player
      actions["check"] = false
      actions["call"] = false
      actions["raise"] = false
      return actions
    end

    if player.pots.empty?
      pots = player.table.pots
    else
      pots = player.pots
    end
    amount = player.amount
    placedBets = 0
    highestBets = 0

    pots.each do |pot| 
    	placedBets = placedBets + pot.getPlayerAmount(player.id)
    	highestBets = highestBets + pot.highest_bet
    end

    if placedBets == highestBets
    	actions["check"] = true
    else
    	actions["check"] = false
    end

    if amount <= 0 
    	actions["call"] = false
    else
    	actions["call"] = true
    end

    if (highestBets - placedBets) < amount
    	actions["raise"] = true
    else 
    	actions["raise"] = false
    end	

    p "highest---------------------------------- " + highestBets.to_s
    p "placed----------------------------------- " + placedBets.to_s

    actions["callAmount"] = highestBets - placedBets

    return actions
  end
  
  def whatsNext(table)

  	index = table.player_turn

  	players = table.players


    activePlayers = 0
    players.each do |player|
      if player.folded == false # || player.left_game_at != nil
        activePlayers += 1
      else
        p player
      end
    end

    if (table.cards_on_table.count == 5 && table.last_raise == index) || activePlayers == 1
      return "determineWinner"
    end 


  	i = 0
  	while i < 8 do
      index = (index+1) % 8

  		if players[index].folded != true 
        if index == table.last_raise
          return "nextRound"
        end
        break
  		end

      if index == table.last_raise
        return "nextRound"
      end

  	end

    p "INDEX -------------- " + index.to_s

  	return "nextPlayer"

  end
   
  

end
