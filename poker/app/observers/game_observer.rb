class GameObserver < ActiveRecord::Observer
  
  observe :table, :pot, :player

  def after_create(entity)
    
  end

  def after_update(entity)
    case entity
    when Table
      broadcast(entity)
    end
  end

  def broadcast(table)
    # constructing players hash
    players = []
    table.players.each do |p|
      # stub for the possibleActions until the GameLogic is implemented
      possibleActions = {"check" => false, "call" => true, 
        "raise" => true, "callAmount" => 10}
      player = {"id" => p.id, "name" => p.name, "chips" => p.amount, 
        "lastAction" => p.last_action, "possibleActions" => possibleActions}

      players << player
    end

    tableHash = {"playerTurn" => table.player_turn, "button" => table.button, 
      "tableNumber" => table.id, "blindAmount" => table.blind_amount, 
      "sharedCards" => table.cards_on_table, "pot" => table.getTotalPot}


    result = {"players" => players, "table" => tableHash}
    Juggernaut.publish("#{table.id}", result)
    # if not table.changes.length == 1
      # Juggernaut.publish("#{table.id}", table.changes.to_json)
    # end

  end
end