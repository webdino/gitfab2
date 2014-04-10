json.success true
json.class item.class.name.underscore
json.id item.id
if item.is_a? Status
  json.html (render "recipes/status_item", item: item)
else
  json.html (render "recipes/item", item: item)
end
