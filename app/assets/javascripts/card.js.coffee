$ ->
  formContainer = $(document.createElement("div"))
  formContainer.attr "id", "card-form-container"
  document.body.appendChild formContainer.get(0)

  containerSelector = ""
  $(".new-card-link").click (event) ->
    event.preventDefault() 
    link = $(this)
    action = link.attr "data-action"
    containerSelector = link.attr "data-container"
    $.get action, (data) ->
      formContainer.html data.html
      formContainer.show()
      formContainer.find "form"

  $(document).on "ajax:success", ".card-form", (xhr, data) -> 
    container = $(containerSelector)
    if container.get(0).nodeName is "ul"
      li = $(document.createElement("li"))
      li.html data.html
      container.append li
    else 
      $(container).append $(data.html)

  $(document).on "ajax:complete", ".card-form", (xhr, data) -> 
    formContainer.hide()