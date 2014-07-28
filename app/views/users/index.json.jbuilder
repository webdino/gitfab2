json.array!(@users) do |user|
  json.extract! user, :id, :name, :slug
  json.url user_url(user, format: :json)
end
