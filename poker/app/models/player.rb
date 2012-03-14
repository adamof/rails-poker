class Player < ActiveRecord::Base
  belongs_to              :tournament
  belongs_to              :table
  has_and_belongs_to_many :pots
end