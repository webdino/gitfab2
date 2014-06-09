class NotesController < ApplicationController
  layout "project"

  before_action :load_owner
  before_action :load_project
  before_action :load_note

  def show
  end

  private
  def load_owner
    owner_id = params[:owner_name]
    @owner = User.find(owner_id) || Group.find(owner_id)
  end

  def load_project
    @project = @owner.projects.find params[:project_id]
  end

  def load_note
    @note = @project.note
  end
end
