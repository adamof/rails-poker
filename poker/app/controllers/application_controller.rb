class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def after_sign_in_path_for(resource)
    return current_player.table || Table.first || root_path
  end
  
  def after_sign_out_path_for(resource)
    return root_path
  end

end
