module GameLogic

  # don't allow it to use the same cards (remove doubles)
  PokerHand.allow_duplicates = false

  # determine the winner
  def determineWinner(table)
    
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
      end

      # find out how many people share the pot
      pot.player_amounts.each do |player_id, amount|
        if winningHand == playerHands[player_id]
          ++winners
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
        if winners.key? potWinner_id
          results[potWinner_id] += amount
        else
          results[potWinner_id] = amount
        end
      end
    end

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

    pots = player.pots
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

    return actions
  end
  
  def whatsNext(table)

  	index = table.player_turn

  	players = table.players
  	index = (index+1) % 8

  	i = 0
  	while i < 8 do
  		if players[index].folded == true || players[index].left_game_at != nil
  			index = (index+1) % 8
  		else 
  			break
  		end
  	end

  	notFolded = 0
  	players.each do |player|
  		if player.folded == true || player.left_game_at != nil
  			notFolded += 1
  		else
        p player
      end
  	end

  	if (table.cards_on_table.count == 5 && table.last_raise == index) || notFolded == 1
  		return "determineWinner"
  	end	

  	if table.last_raise == index 
  		return "nextRound"
  	end

  	return "nextPlayer"

  end
   
  

end
