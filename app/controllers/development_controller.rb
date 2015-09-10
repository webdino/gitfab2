class DevelopmentController < ApplicationController
  def su
    case params[:commit]
    when 'su'
      session[:su] = params[:user_id]
    when 'reset'
      session[:su] = nil
    end
    redirect_to request.referer
  end
end
