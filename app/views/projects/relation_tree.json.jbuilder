def json_ltree_builder(json, ltree_item)
  json.name ltree_item.owner.name + "/" + ltree_item.name
  json.url root_url.chop + project_path(ltree_item.owner.slug, ltree_item.name)
  if ltree_item.owner.slug == @project.owner.slug && ltree_item.name == @project.name
    json.this true
  else
    json.this false
  end

  children = ltree_item.derivatives
  unless children.empty?
    json.children do
      json.array! children do |child|
        json_ltree_builder(json, child)
      end
    end
  end
end

json_ltree_builder(json, @root)
