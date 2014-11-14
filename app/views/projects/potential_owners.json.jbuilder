json.array!(@project.potential_owners) do |user|
  json.extract! user, :id, :name, :slug
end
