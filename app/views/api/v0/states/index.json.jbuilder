json.array! @states do |state|
  json.id state.id.to_str
  json.(state,
    :created_at,
    :updated_at,
    :title,
    :position
  )

  json.figures state.figures do |figure|
    json.photo_url (root_url.chop + figure.content.url)
    json.youtube_url figure.link
  end

  if @project.owner_type == 'User'
    json.project_url (root_url.chop + api_v0_user_project_path(@owner, @project))
    json.url (root_url.chop + api_v0_user_project_recipe_state_path(@owner, @project, state))
    json.annotations_url (root_url.chop + api_v0_user_project_recipe_state_annotations_path(@owner, @project, state))
  else
    json.project_url (root_url.chop + api_v0_group_project_path(@owner, @project))
    json.url (root_url.chop + api_v0_group_project_recipe_state_path(@owner, @project, state))
    json.annotations_url (root_url.chop + api_v0_group_project_recipe_state_annotations_path(@owner, @project, state))
  end
end
