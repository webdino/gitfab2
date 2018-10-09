class OwnersController < ApplicationController
  def index
    @owners = User.order(name: :asc).all + Group.active.order(name: :asc).all
  end

  def show
    @owner = Owner.find(params[:owner_name])
    @projects = @owner.projects.active.includes(:figures).order(updated_at: :desc)
    if @owner.is_a?(User)
      @liked_projects = @owner.liked_projects.order(updated_at: :desc)
    end
    render layout: 'dashboard'
  end
end
