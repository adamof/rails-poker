class Table < ActiveRecord::Base
  belongs_to  :tournament
  has_many    :players
  has_many    :pots  
  serialize   :cards_on_table
  serialize   :cards_in_deck
  after_update :broadcast
  
  include GameLogic

  def broadcast
    # constructing players hash
    players = []
    self.players.each do |p|
      # stub for the possibleActions until the GameLogic is implemented
      possibleActions = {"check" => false, "call" => true, 
        "raise" => true, "callAmount" => 10}
      player = {"id" => p.id, "name" => p.name, "chips" => p.amount, 
        "lastAction" => p.last_action, "possibleActions" => possibleActions}

      players << player
    end
    turn = self.player_turn
    p "##----#" + turn.to_s + "---------#"
    tableHash = {"playerTurn" => self.players[turn].id, "button" => self.players[self.button], 
      "tableNumber" => self.id, "blindAmount" => self.blind_amount, 
      "sharedCards" => self.cards_on_table, "pot" => self.getTotalPot}


    result = {"players" => players, "table" => tableHash}
    Juggernaut.publish("#{self.id}", result)
    # if not self.changes.length == 1
      # Juggernaut.publish("#{self.id}", self.changes.to_json)
    # end

  end

  def playerAdded
    self.startGame if self.players.count==8
  end

  def startGame
    self.started = true
    self.blind_amount = 50
    self.button = 0
    self.save
    self.startHand
  end

  def getTotalPot
    result = 0
    self.pots.each do |pot|
      result += pot.amount
    end
    return result
  end
  
  def nextPlayerTurn
    self.incrementPlayerTurn
    self.players[self.player_turn].broadcast
  end
  
  def dealDeck
    @cards_in_deck = []
    Card::SUITS.each_byte do |suit|
      # careful not to double include the aces...
      Card::FACES[1..-1].each_byte do |face|
        @cards_in_deck.push(Card.new(face.chr, suit.chr).to_s)
      end
    end
    @cards_in_deck = @cards_in_deck.sort_by { rand }
    self.cards_in_deck = @cards_in_deck
    self.save
  end
  
  def dealToPlayers
    self.players.each do |p|
      p.card_1 = GameLogic.dealCard(self.cards_in_deck)
      self.cards_in_deck.delete(p.card_1)
      p.card_2 = GameLogic.dealCard(self.cards_in_deck)
      self.cards_in_deck.delete(p.card_2)
      p.save!
      self.save!
    end
  end
  
  def startHand
    self.dealDeck
    self.dealToPlayers
    self.players.each do |p|
      p.folded = false
      p.last_action = nil
      p.save!
    end
    self.cards_on_table = []
    self.save!
    self.determineStartingPlayer("first")
    self.takeBlinds
    player = self.players[self.player_turn]
    Juggernaut.publish("#{self.id}/#{player.id}", GameLogic.possibleActions(player).to_json)
  end
  
  def nextRound
    p "---------------------------------------NEXT ROUND----------"
    if self.cards_on_table.blank?
      self.cards_on_table << GameLogic.dealCard(self.cards_in_deck)
      self.cards_on_table << GameLogic.dealCard(self.cards_in_deck)
      self.cards_on_table << GameLogic.dealCard(self.cards_in_deck)
    else
      self.cards_on_table << GameLogic.dealCard(self.cards_in_deck)
    end
    self.determineStartingPlayer("")
    player = self.players[self.player_turn]
    player.broadcast
  end
  
  def incrementPlayerTurn
    startingIndex = self.player_turn + 1
    while(true)
      player = self.players[(startingIndex % self.players.count)]
      if player.left_game_at == nil && player.folded == false
        self.player_turn = (startingIndex % self.players.count)
        self.save!
        return
      else
        startingIndex += 1
      end
    end
  end
  
  def getCurrentPlayer
    return self.players[self.player_turn]
  end

  def determineStartingPlayer(condition)
    
    if condition == "first"
      startingIndex = (self.button + 3)
    else
      startingIndex = (self.button + 1)
    end
    while(true)
      player = self.players[startingIndex % self.players.count]
      if player.active?
        self.player_turn = startingIndex
        self.last_raise = startingIndex
        self.save!
        return
      else
        startingIndex += 1
      end
    end
    
  end
  
  def takeBlinds
    pot = Pot.new
    pot.table = self
    pot.save!
    
    smallBlind = self.button + 1
    
    while(true)
      player = self.players[(smallBlind % self.players.count)]
      if player.active?
        if player.amount > (self.blind_amount / 2)
          pot.addAmount(player, (self.blind_amount / 2))
        else
          pot.addAmount(player, player.amount)
          second_pot = Pot.new
          second_pot.table_id = self.id
          second_pot.save!
        end
        bigBlind = (smallBlind + 1) % self.players.count
        while(true)
          player = self.players[bigBlind % self.players.count]
          if player.active?
            if player.amount > self.blind_amount
              if second_pot == nil
                pot.addAmount(player, self.blind_amount)
                return
              else
                second_pot.addAmount(player, self.blind_amount)
                return
              end
            else
              pot.addAmount(player, player.amount)
              if second_pot == nil
                second_pot = Pot.new
                second_pot.table_id = self.id
                second_pot.save!
              else
                third_pot = Pot.new
                third_pot.table_id = self.id
                third_pot.save!
              end
              return
            end
          else
            bigBlind += 1
          end
        end           
      else
        smallBlind += 1
      end
    end
  end
  
  def doNext
    nextAction = GameLogic.whatsNext(self)
    if nextAction == "determineWinner"
      Juggernaut.publish("#{self.id}", GameLogic.determineWinner(self).to_json)
      self.startHand
    elsif nextAction == "nextRound"
      self.nextRound
    else
      self.nextPlayerTurn
    end
  end

  class << self    
    def subscribe
      Juggernaut.subscribe do |event, data|
        player_id = data["meta"] && data["meta"]["table"]
        next unless player_id
        case event
        when :subscribe
          Juggernaut.publish(data["meta"]["table_id"], "Connected player #{data["meta"]["player_id"]}")
          self.playerJoin(data["meta"]["player_id"])
        when :unsubscribe
          Juggernaut.publish(data["meta"]["table_id"], "Disconnected player #{data["meta"]["player_id"]}")
          self.playerLeave(data["meta"]["player_id"])
        end
      end
    end
    def playerJoin(player_id)
      @player = Player.find(player_id)
      @player.connections = 1
      @player.left_game_at = nil
      @player.save
      @player.table.save
    end
    def playerLeave(player_id)
      @player = Player.find(player_id)
      @player.connections = 0
      @player.left_game_at = Time.now
      @player.save
    end
  end
end
