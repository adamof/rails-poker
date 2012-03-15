class TablesController < ApplicationController
  def index
    @tables = Tables.all
    render 'index'
  end
  def show

  end
  def bet
    
  end
  def fold
    
  end
  def check
    
  end
  def raise
    
  end
end