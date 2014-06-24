window.createCardWrapper = (list, card) ->
  if list.get(0).tagName.toLowerCase() is "ul"
    li = $(document.createElement("li"))
    li.append card
  li

window.getCardWrapper = (card) ->
  parent = card.parent()
  if parent.get(0).tagName.toLowerCase() is "li"
    return parent
  card

window.validateForm = (event) ->
  validated = false
  $(".card-form:first-child .validate").each (index, element) ->
    if $(element).val() != ""
      validated = true
  if validated == false
    alert "You cannot make empty card."
    event.preventDefault()

$ ->
  formContainer = $(document.createElement("div"))
  formContainer.attr "id", "card-form-container"
  document.body.appendChild formContainer.get(0)

  hideFormContainer = ->
    formContainer.empty()
    formContainer.hide()

  $(document).on "click", ".new-card, .edit-card, .delete-card", () ->
    formContainer.show()

  $(document).on "ajax:error", ".new-card, .edit-card, .delete-card", (event, xhr, status, error) ->
    alert error.message
    event.preventDefault()
    hideFormContainer()

  $(document).on "click", ".card-form > .submit", (event) ->
    validateForm event

  $(document).on "submit", ".card-form", ->
    $(this).find(".submit").hide()

  $(document).on "ajax:success", ".new-card", (xhr, data) ->
    link = $(this)
    list = $(link.attr "data-list")
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      wrapper = createCardWrapper list, $(data.html)
      list.append wrapper
      list.trigger "card-order-changed"
    .bind "ajax:complete", (xhr, data) ->
      hideFormContainer()
    .bind "ajax:error", (event, xhr, status, error) ->
      alert error.message

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    link = $(this)
    card = link.closest(link.attr "data-container")
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      card.replaceWith data.html
    .bind "ajax:complete", (xhr, data) ->
      hideFormContainer()
    .bind "ajax:error", (event, xhr, status, error) ->
      alert error.message

  $(document).on "ajax:success", ".delete-card", (xhr, data) ->
    link = $(this)
    card = link.closest(link.attr "data-container")
    wrapper = getCardWrapper card
    list = wrapper.parent()
    wrapper.remove()
    list.trigger "card-order-changed"
    hideFormContainer()
