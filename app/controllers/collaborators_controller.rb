class CollaboratorsController < ApplicationController
  before_action :load_owner
  before_action :load_project

  def index
  end

  private

    def load_owner
      owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
      @owner = Owner.find(owner_id)
    end

    def load_project
      @project = @owner.projects.friendly.find params[:project_id]
    end
end
