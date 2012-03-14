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

    # table = {playerTurn : int, button : int, tableNumber : int, 
      # blindAmount : int, sharedCards : [“3D”, “KH”], pot : int}

    # Juggernaut.publish("channel1", "updated table #{self.id}")
    # Juggernaut.publish("channel1", self.to_json)
    Juggernaut.publish("channel1", players)
    # Juggernaut.publish("channel1", "changes are #{self.changes}")

    # Juggernaut.publish("channel2", "updated table #{self.id} on 2")

  end
end