json.id @project.id.to_str
json.(@project,
  :created_at,
  :updated_at,
  :title,
  :description,
  :is_private,
  :license,
  :owner_type,
  :owner_id
)
json.figures @project.figures do |figure|
  json.photo_url figure.content.url
  json.youtube_url figure.link
end

json.collaborators @project.collaborators, :name

#TODO: 本当はusageもstatesと同様にurlに絞ったほうがいいんだろうな
json.usages @project.usages do |usage|
  json.title usage.title
  json.description Sanitize.clean(usage.description)
  json.figures usage.figures do |figure|
    json.photo_url (root_url.chop + figure.content.url)
    json.youtube_url figure.link
  end
end

if @project.owner_type == 'User'
  json.url (root_url.chop + api_v0_user_project_path(@owner, @project))
  json.states_url (root_url.chop + api_v0_user_project_recipe_states_path(@owner, @project))
else
  json.url (root_url.chop + api_v0_group_project_path(@owner, @project))
  json.states_url (root_url.chop + api_v0_group_project_recipe_states_path(@owner, @project))
end
