json.id @tag.id
json.name @tag.name
json.html (render "tag.html", tag: @tag, recipe: @recipe)
