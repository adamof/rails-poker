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
  
  
  def broadcast    
    Juggernaut.publish("#{self.table_id}/#{self.id}", self.changes.to_json)
  end
end