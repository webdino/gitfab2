class GlobalProjectsController < ApplicationController
  layout "global_projects"

  def index
    q = params[:q]

    if q.present?
      @projects = Project.solr_search do |s|
        s.fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        s.without :is_private, true
        # s.order_by :updated_at, :desc
      end.results

      @is_searching = true
      @query = q

    elsif !q.nil?
      @projects = Project.all().in(is_private: [false, nil]).page(params[:page]).order("updated_at DESC")
      @is_searching = true

    else
      @projects = Project.all().in(is_private: [false, nil]).page(params[:page]).order("updated_at DESC")

      featured_projects_all = Feature.projects
      @featured_project_groups = []
      @featured_project_group_titles = []

      if featured_projects_all.length >= 3

        first_featured_projects = featured_projects_all.first().featured_items || []
        second_featured_projects = featured_projects_all.second().featured_items || []
        third_featured_projects = featured_projects_all.projects.third().featured_items || []

        @featured_project_group_titles.push(featured_projects_all.first().name)
                                      .push(featured_projects_all.second().name)
                                      .push(featured_projects_all.third().name)

        featured_projects = []
        first_featured_projects.each do |project|
          project = Project.find project.target_object_id
          featured_projects.push project
        end
        @featured_project_groups.push featured_projects

        featured_projects = []
        second_featured_projects.each do |project|
          project = Project.find project.target_object_id
          featured_projects.push project
        end
        @featured_project_groups.push featured_projects

        featured_projects = []
        third_featured_projects.each do |project|
          project = Project.find project.target_object_id
          featured_projects.push project
        end
        @featured_project_groups.push featured_projects

      end

      featured_groups_all = Feature.groups
      @featured_groups = []

      if featured_groups_all.length > 0

        featured_groups = featured_groups_all.first().featured_items || []
        if featured_groups.length > 0
          featured_groups.each do |group|
            group = Group.find group.target_object_id
            @featured_groups.push group
          end
        end
      end

      @is_searching = false
    end

    @selected_tags = []
    file_path = "#{Rails.root}/config/selected-tags.yml"
    tags_list = YAML.load_file file_path

    if tags_list.present?
      tags_list.each do |tag_name|
        @selected_tags.push tag_name
      end
    end

    @selected_tools = []
    file_path = "#{Rails.root}/config/selected-tools.yml"
    tools_list = YAML.load_file file_path

    if tools_list.present?
      tools_list.each do |tool_name|
        @selected_tools.push tool_name
      end
    end

    @selected_materials = []
    file_path = "#{Rails.root}/config/selected-materials.yml"
    materials_list = YAML.load_file file_path

    if materials_list.present?
      materials_list.each do |material_name|
        @selected_materials.push material_name
      end
    end


  end
end
