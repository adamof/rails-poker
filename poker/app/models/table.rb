class Table < ActiveRecord::Base
  belongs_to  :tournament
  has_many    :players
  has_many    :pots  
  serialize   :cards_on_table
  serialize   :cards_in_deck
  

  def playerAdded
    self.startGame if self.players.count==8
  end

  def startGame
    self.started = true
    self.blind_amount = 50
    self.button = 0
    self.save
    # self.startHand
  end

  def getTotalPot
    result = 0
    self.pots.each do |pot|
      result += pot.amount
    end
    return result
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
      @player.connections += 2
      @player.save
    end
    def playerLeave(player_id)
      @player = Player.find(player_id)
      @player.connections -= 1
      @player.save
    end
  end
end