json.array!(@owners) do |owner|
  json.extract! owner, :id, :name, :slug
end
