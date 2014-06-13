$ ->
  formContainer = $(document.createElement("div"))
  formContainer.attr "id", "card-form-container"
  document.body.appendChild formContainer.get(0)

  hideFormContainer = ->
    formContainer.empty()
    formContainer.hide()

  $(document).on "click", ".new-card, .edit-card, .delete-card", () ->
    formContainer.show()

  $(document).on "ajax:error", ".new-card, .edit-card, .delete-card", (xhr, status, error) ->
    alert error.message
    hideFormContainer()

  $(document).on "submit", ".card-form", () ->
    $(this).find(".submit").hide()

  $(document).on "ajax:success", ".new-card", (xhr, data) ->
    link = $(this)
    list = $(link.attr "data-list")
    formContainer.html data.html
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      if list.get(0).nodeName is "ul"
        li = $(document.createElement("li"))
        li.html data.html
        list.append li
      else 
        list.append $(data.html)
     .bind "ajax:complete", (xhr, data) -> 
        hideFormContainer()
     .bind "ajax:error", (xhr, status, error) -> 
       alert error.message

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    link = $(this)
    container = link.parents(link.attr "data-container")
    formContainer.html data.html
    formContainer.find "form"    
    .bind "ajax:success", (xhr, data) ->
      container.replaceWith data.html
    .bind "ajax:complete", (xhr, data) -> 
       hideFormContainer()
    .bind "ajax:error", (xhr, status, error) -> 
       alert error.message

  $(document).on "ajax:success", ".delete-card", (xhr, data) ->
    link = $(this)
    container = link.parents(link.attr "data-container")
    container.remove()
    hideFormContainer()