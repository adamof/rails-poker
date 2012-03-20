include GameLogic

class Player < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable
  

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :encrypted_password, :pots, :table
  belongs_to              :tournament
  belongs_to              :table
  has_and_belongs_to_many :pots
  after_update :broadcast
  after_create :assignToTable

  def assignToTable
    if Table.all.size == 0
      t = Table.new
      t.save
      self.table = t
    elsif Table.last.players.count < 8
      self.table = Table.last
      Table.last.save
    else
      t = Table.new
      t.save
      self.table = t
    end
    self.save
    self.amount = 1000
    self.save
    self.table.playerAdded
  end
  
  def broadcast
    cardsHash = {"card1" => self.card_1, "card2" => self.card_2}
    actions = GameLogic.possibleActions(self)
    result = {"cards" => cardsHash, "actions" => actions}
    Juggernaut.publish("#{self.table_id}/#{self.id}", result.to_json)
  end
  
  def active?
    return self.amount > 0 && self.left_game_at == nil && self.folded != true
  end
end