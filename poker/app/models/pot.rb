class Pot < ActiveRecord::Base
  has_and_belongs_to_many :players
  belongs_to              :table
  after_update            :broadcast

  def broadcast
    Juggernaut.publish("#{self.table.id}", "POT --> " + self.changes.to_json)
  end
end