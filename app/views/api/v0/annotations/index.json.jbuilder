json.array! @annotations do |annotation|
  json.id annotation._id
  json.(annotation,
    :created_at,
    :updated_at,
    :title,
    :description,
    :position
  )

  json.figures annotation.figures do |figure|
    json.photo_url (root_url.chop + figure.content.url)
    json.youtube_url figure.link
  end

  if @project.owner_type == 'User'
    json.project_url (root_url.chop + api_v0_user_project_path(@owner, @project))
    json.state_url (root_url.chop + api_v0_user_project_recipe_state_path(@owner, @project, @state))
    json.url (root_url.chop + api_v0_user_project_recipe_state_annotation_path(@owner, @project, @state, annotation))
  else
    json.project_url (root_url.chop + api_v0_group_project_path(@owner, @project))
    json.state_url (root_url.chop + api_v0_group_project_recipe_state_path(@owner, @project, @state))
    json.url (root_url.chop + api_v0_group_project_recipe_state_annotation_path(@owner, @project, @state, annotation))
  end
end
