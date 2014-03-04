class SessionsController < Devise::SessionsController
  def create
    warden.authenticate! scope: resource_name
    render json: {success: true} 
  end
end
