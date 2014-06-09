json.array! @projects do |project|
  json.extract! project, :id, :title, :name
  json.url project_url(hoge, format: :json)
end
