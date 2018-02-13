class GlobalProjectsController < ApplicationController
  layout 'global_projects'

  def index
    q = params[:q]
    published_projects = Project.published.includes(:figures, :owner, recipe: :states, note: :note_cards)

    if q.present?
      query = q.force_encoding 'utf-8'
      @projects = published_projects.ransack(draft_cont_all: query.split(/\p{space}+/)).result.page(params[:page])
      @is_searching = true
      @query = query

    elsif !q.nil?
      @projects = published_projects.page(params[:page]).order('updated_at DESC')
      @is_searching = true

    else
      @projects = published_projects.page(params[:page]).order('updated_at DESC')
      @featured_project_groups = Feature.projects.length >= 3 ? view_context.featured_project_groups : []
      @featured_groups = Group.includes(:members, :projects).order(projects_count: :desc).limit(3)
      @is_searching = false
    end

    selected_tags_length = 30
    @all_tags = Tag.where(taggable_type: 'Project').where.not(name: '').group(:name).order('COUNT(id) DESC').pluck(:name)
    @selected_tags = view_context.selected_tags @all_tags, selected_tags_length

    @selected_tools = view_context.selected_tools
    @selected_materials = view_context.selected_materials
  end
end
