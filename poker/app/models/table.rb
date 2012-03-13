class Table < ActiveRecord::Base
  belongs_to  :tournament
  has_many    :players
  has_many    :pots  
end