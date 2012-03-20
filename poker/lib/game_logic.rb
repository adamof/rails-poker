module GameLogic

  # don't allow it to use the same cards (remove doubles)
  PokerHand.allow_duplicates = false

  # determine the winner
  def determineWinner(players, pots, cardsOnTable)
    
    # arrays for results
    playerResults = []
    results = {}
    
    # get the hands
    for player in players
      
      # add the hash to the array
      playerResults << getHash(player, cardsOnTable)
    end
    
    # cycle through the pots
    pots.each do |pot|
      
      #local array for winners
      winners = []
      
      # cycle through the players
      for i in 0...playerResults.length
        
        #determine if the player has contributed
        if(contributed(pot, playerResults[i]))
          
          # if there are no winners, add this player to the winner list
          # else determine if the player is a winning hand
          if(winners.length == 0)
            winners << player
          elsif
            
            # determine if the player hand is a winner
            if playerResults[i]["hand"] > winners[0]["hand"]
              
              # clear the array then add the player
              # ASSUMPTION:  all players previously in the array have the same
              #   hand value (should be guaranteed due to implementation)
              winners.clear
              winners << playerResults[i]
            elsif playerResults[i]["hand"] == winners[0]["hand"]
              
              # if the player has the same hand as the winner
              # then just add the player to the end of the array
              winners << playerResults[i]
            end
          end
        end
      end
      
      # determine the amount won by each of the players
      amount = pot.amount / winners.length
      p winners
      # go through the winners and add them to the array
      winners.each do |winner|
        
        # load the hash of the result into the overall results
        results[winner["player"]] = amount
      end
    end
    
    # holder for best hand data
    bestHand = playerResults[0]
    
    # determine the best hand out of all
    for i in 1...playerResults.length
      
      # if the current results have a better hand, store that as the
      # best hand
      if playerResults[i]["hand"] > bestHand["hand"]
        bestHand = playerResults[i];
      end
    end
    
    # return the result
    return {"winners"=>results, "bestHand"=>bestHand["hand"]}
  end

  # gets the hash representation of the card player combination
  def getHash(player, cards)
    
    # load the cards (all possible cards
    playerCards = "#{player.card_1} #{player.card_2}"
    # return the hash
    return {"player"=>player.id, "hand"=>PokerHand.new(playerCards)}
  end

  # determine if a person has contributed to the pot
  def contributed(pot, player)
    
    return pot.player_amounts.key? player["player"]
    # go through all the players in the pot
    # for value in 0...pot.players_amounts.length
      
    #   # if the player is the specified value...
    #   if(pot.players_amounts[value] == player["player"].id)
        
    #     # return true
    #     return true
    # #   end
    # end
      
    # # if no return has been made, then the player isn't in the pot
    # return false
  end
  
  def dealCard(cardsInDeck)
  	cardIndex = rand(cardsInDeck.length)
  	card = cardsInDeck[cardIndex]
  	return card
  end
  
  def possibleActions(player)
    pots = player.pots
    table = player.table
    actions = Hash.new
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
  

end