class GlobalProjectsController < ApplicationController
  layout 'global_projects'

  def index
    q = params[:q]

    if q.present?
      query = q.force_encoding 'utf-8'

      search_by_projects = Project.published.ransack(name_or_title_or_description_cont_all: query.split).result

      search_by_users = Project.published.ransack(owner_of_User_type_name_or_owner_of_User_type_fullname_or_owner_of_User_type_url_or_owner_of_User_type_location_cont_all: query.split).result

      search_by_groups = Project.published.ransack(owner_of_Group_type_name_or_owner_of_Group_type_url_or_owner_of_Group_type_location_cont_all: query.split).result

      search_by_tags = Project.published.ransack(tags_name_cont_all: query.split).result

      search_by_states = Project.published.ransack(recipe_states_description_cont_all: query.split).result
      # 検索結果から重複を取り除き、その配列をupdated_atで降順にソートする
      results = (search_by_projects | search_by_users | search_by_groups | search_by_tags | search_by_states).sort_by(&:updated_at).reverse
      @projects = Kaminari.paginate_array(results).page(params[:page])

      @is_searching = true
      @query = query

    elsif !q.nil?
      @projects = Project.published.page(params[:page]).order('updated_at DESC')
      @is_searching = true

    else
      @projects = Project.published.page(params[:page]).order('updated_at DESC')
      @featured_project_groups = Feature.projects.length >= 3 ? view_context.featured_project_groups : []
      @featured_groups = Group.order(projects_count: :desc).limit(3)
      @is_searching = false
    end

    selected_tags_length = 30
    @all_tags = Tag.where(taggable_type: 'Project').where.not(name: '').group(:name).order('COUNT(id) DESC').pluck(:name)
    @selected_tags = view_context.selected_tags @all_tags, selected_tags_length

    @selected_tools = view_context.selected_tools
    @selected_materials = view_context.selected_materials
  end
end
