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
    self.table = Table.first_or_create
    if self.table.players.count > 8
      self.table = Table.new
    end
    self.amount = 1000
    self.save
    self.table.playerAdded
  end
  
  def broadcast    
    Juggernaut.publish("#{self.table_id}/#{self.id}", 
      "PLAYER --> " + self.changes.to_json)
  end
  
  def active?
    return self.amount > 0 && self.left_game_at == nil && self.folded != true
  end
end