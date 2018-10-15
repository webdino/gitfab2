def json_ltree_builder(json, ltree_item)
  if can? :read, ltree_item
    json.name ltree_item.owner.name + '/' + ltree_item.name
    json.url root_url.chop + project_path(ltree_item.owner.slug, ltree_item.name)
  else
    if ltree_item.is_deleted
      json.name 'deleted project'
      json.url root_url.chop
    elsif ltree_item.is_private
      json.name 'private project'
      json.url root_url.chop
    end
  end
  if ltree_item.owner.slug == @project.owner.slug && ltree_item.name == @project.name
    json.this true
  else
    json.this false
  end

  children = ltree_item.derivatives
  return if children.empty?
  json.children do
    json.array! children do |child|
      json_ltree_builder(json, child)
    end
  end
end

json_ltree_builder(json, @root)
