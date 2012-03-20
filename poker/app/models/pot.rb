class Pot < ActiveRecord::Base
  has_and_belongs_to_many :players
  belongs_to              :table
  after_update            :broadcast
  after_create            :init
  serialize               :player_amounts

  def broadcast
    Juggernaut.publish("#{self.table.id}", "POT --> " + self.changes.to_json)
  end

  def getPlayerAmount(player_id)
    return self.player_amounts[player_id] || 0
  end

  def init
    self.player_amounts={}
    self.save
  end

  def addAmount(player, amount)
    self.player_amounts[player.id] = 
      self.getPlayerAmount(player.id) + amount
    self.amount += amount
    player.amount -= amount
    player.save
    self.save
  end

end