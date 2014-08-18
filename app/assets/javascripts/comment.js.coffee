$ ->
  $(document).on "ajax:success", ".delete-comment", (xhr, data) ->
    link = $ this
    li = link.closest "li"
    li.remove()

  $(document).on "ajax:success", ".comment-form", (xhr, data) ->
    form = $ this
    ul = form.siblings ".comments"
    ul.append data.html

  $(document).on "ajax:error", ".comment-form, .delete-comment", (event, xhr, status, error) ->
    alert error.message
    event.preventDefault()
