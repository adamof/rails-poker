class Table < ActiveRecord::Base
  belongs_to  :tournament
  has_many    :players
  has_many    :pots  
  after_update :broadcast

  def broadcast
    # Juggernaut.publish("channel1", "updated table #{self.id}")
    # Juggernaut.publish("channel1", self.to_json)
    Juggernaut.publish("channel1", "updated table #{self.id} on 1")
    Juggernaut.publish("channel1", "changes are #{self.changes}")

    # Juggernaut.publish("channel2", "updated table #{self.id} on 2")

  end
end