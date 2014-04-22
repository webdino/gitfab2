json.success true
json.class @comment.class.name.underscore
json.id @comment.id
json.html (render "comment", comment: @comment)
