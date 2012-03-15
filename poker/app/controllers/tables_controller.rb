class TablesController < ApplicationController
  def index
    @tables = Table.all
    render 'index'
  end
  def show
    @table = Table.find(params[:id])
  end
  def bet
    
  end
  def fold
    @table = Player.find(params[:id]).table
    @table.save

    render :nothing => true
  end
  def check
    
  end
  def raiseBet
    
  end
end