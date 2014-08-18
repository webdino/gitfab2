$ ->
  $(document).on "ajax:success", ".delete-tag", (xhr, data) ->
    link = $ this
    li = link.closest "li"
    li.remove()

  $(document).on "ajax:success", "#tag-form", (xhr, data) ->
    form = $ this
    ul = form.siblings(".line").find ".tags"
    ul.append data.html
    list = ul.find "li"
    if list.length > 10
      link = $(list.get(0)).find ".delete-tag"
      link.click()

  $(document).on "ajax:error", "#tag-form, .delete-tag", (event, xhr, status, error) ->
    alert error.message
    event.preventDefault()

  $(document).on "click", "#show-tag-form", (event) ->
    $("#tag-form").show()
    $(this).hide()
    event.preventDefault()
