class Tournament < ActiveRecord::Base
  has_many    :tables
  has_many    :players  
end