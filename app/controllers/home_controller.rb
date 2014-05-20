class HomeController < ApplicationController
  layout "home"

  def index
    @recipes = Recipe.order("id DESC").page params[:page]
  end

  def proxy_to_userhome
    redirect_to recipes_path owner_name: current_user.name
  end

  def su
    case params[:commit]
    when "su"
      session[:su] = params[:user_id]
    when "reset"
      session[:su] = nil
    end
    redirect_to request.referer
  end
end
