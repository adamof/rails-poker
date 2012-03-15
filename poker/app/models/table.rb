class Table < ActiveRecord::Base
  belongs_to  :tournament
  has_many    :players
  has_many    :pots  
  after_update :broadcast
  serialize   :cards_on_table
  serialize   :cards_in_deck
  def broadcast
    # constructing players hash
    players = []
    self.players.each do |p|
      # stub for the possibleActions until the GameLogic is implemented
      possibleActions = {"check" => false, "call" => true, 
        "raise" => true, "callAmount" => 10}
      player = {"id" => p.id, "name" => p.name, "chips" => p.money, 
        "lastAction" => p.last_action, "possibleActions" => possibleActions}

      players << player
    end

    table = {"playerTurn" => self.player_turn, "button" => self.button, 
      "tableNumber" => self.id, "blindAmount" => self.blind_amount, 
      "sharedCards" => self.cards_on_table, "pot" => self.getTotalPot}


    result = {"players" => players, "table" => table}
    # Juggernaut.publish("#{self.id}", result)
    # if not self.changes.length == 1
      Juggernaut.publish("#{self.id}", "TABLE --> " + self.changes.to_json)
    # end

  end

  def getTotalPot
    result = 0
    self.pots.each do |pot|
      result += pot.amount
    end
    return result
  end
end