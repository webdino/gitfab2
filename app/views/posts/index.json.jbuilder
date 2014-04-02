json.array!(@posts) do |post|
  json.extract! post, :id, :recipe_id, :title, :body
  json.url post_url(post, format: :json)
end
