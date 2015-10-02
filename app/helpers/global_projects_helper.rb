module GlobalProjectsHelper
  def featured_project_groups
    project_groups = {}
    all_featured_projects = Feature.projects
    all_featured_projects.each do |project_group|
      featured_projects = []
      project_group.featured_items.each do |project|
        project = Project.find project.target_object_id
        featured_projects.push project
      end
      project_groups[project_group.name] = featured_projects
    end
    project_groups.to_a
  end

  def featured_groups
    featured_groups_array = Feature.groups.first.featured_items || []
    groups = []
    if featured_groups_array.length > 0
      featured_groups_array.each do |group|
        group = Group.find group.target_object_id
        groups.push group
      end
    end
    groups
  end

  def all_tags(list)
    tags = []
    if list.present?
      list.each do |tag_name|
        tags.push tag_name
      end
    end
    tags
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
    file_path = "#{Rails.root}/config/selected-tools.yml"
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
    file_path = "#{Rails.root}/config/selected-materials.yml"
    list = YAML.load_file file_path
    if list.present?
      list.each do |material_name|
        materials.push material_name
      end
    end
    materials
  end
end
