json.success true
json.class item.class.name.underscore
json.html (render "recipes/#{item.class.name.underscore}", item: item)
