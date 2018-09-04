class OwnersController < ApplicationController
  def index
    @owners = User.order(name: :asc).all + Group.order(name: :asc).all
  end

  def show
    @owner = Owner.find(params[:owner_name])
    @projects = @owner.projects.includes(:figures).order(updated_at: :desc)
    render layout: 'dashboard'
  end
end
