class GlobalProjectsController < ApplicationController
  layout 'global_projects'

  def index
    q = params[:q]
    published_projects = Project.published.includes(:figures, :owner, :note_cards, :states)

    if q.present?
      query = q.force_encoding 'utf-8'
      @projects = published_projects.search_draft(query).page(params[:page])
      @is_searching = true
      @query = query

    elsif !q.nil?
      @projects = published_projects.page(params[:page]).order(updated_at: :desc)
      @is_searching = true

    else
      @projects = published_projects.page(params[:page]).order(updated_at: :desc)
      @featured_project_groups = Feature.projects.count >= 3 ? featured_project_groups : []
      @featured_groups = Group.includes(:members, :projects).order(projects_count: :desc).limit(3)
      @is_searching = false
    end

    selected_tags_length = 30
    @all_tags = Tag.where.not(name: '').group(:name).order(Arel.sql('COUNT(id) DESC')).pluck(:name)
    @selected_tags = selected_tags(@all_tags, selected_tags_length)

    @selected_tools = selected_tools
    @selected_materials = selected_materials
  end

  private

    def featured_project_groups
      project_groups = {}
      all_featured_projects = Feature.projects
      all_featured_projects.each do |project_group|
        ids = project_group.featured_items.select(:target_object_id)
        featured_projects = Project.includes(:figures, :owner, :note_cards, :states)
                                   .where(id: ids).order(likes_count: :desc)
        project_groups[project_group.name] = featured_projects
      end
      project_groups.to_a
    end

    def selected_tags(list, length)
      tags = []
      if list.present? && list.length >= length
        list.slice(0, length).each do |tag_name|
          tags.push tag_name
        end
      end
      tags
    end

    def selected_tools
      tools = []
      file_path = Rails.root.join("config", "selected-tools.yml")
      list = YAML.load_file file_path
      if list.present?
        list.each do |tool_name|
          tools.push tool_name
        end
      end
      tools
    end

    def selected_materials
      materials = []
      file_path = Rails.root.join("config", "selected-materials.yml")
      list = YAML.load_file file_path
      if list.present?
        list.each do |material_name|
          materials.push material_name
        end
      end
      materials
    end
end
