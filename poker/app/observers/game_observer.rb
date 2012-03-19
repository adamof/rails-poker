class GameObserver < ActiveRecord::Observer
  
  observe :table, :pot, :player

  def after_create(table)
    
  end

  def after_update
    
  end
end