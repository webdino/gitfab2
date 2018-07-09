class Admin::ApplicationController < ApplicationController
  layout 'dashboard'

  before_action do
    if !current_user || !current_user.is_system_admin?
      redirect_to(root_path)
    end
  end
end
