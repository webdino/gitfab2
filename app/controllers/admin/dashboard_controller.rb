class Admin::DashboardController < ApplicationController
  include Administration
  layout 'dashboard'

  def index; end
end
