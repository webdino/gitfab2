#= require fancybox

validateForm = (event) ->
  validated = false
  $(".card-form:first-child .validate").each (index, element) ->
    if $(element).val() != ""
      validated = true
  unless validated
    alert "You cannot make empty card."
    event.preventDefault()

$ ->
  formContainer = $(document.createElement("div"))
  formContainer.attr "id", "card-form-container"
  document.body.appendChild formContainer.get(0)

  hideFormContainer = ->
    formContainer.empty()
    formContainer.hide()

  $(document).on "ajax:error", ".new-card, .edit-card, .delete-card", (event, xhr, status, error) ->
    alert error.message
    event.preventDefault()
    hideFormContainer()

  $(document).on "click", ".card-form .submit", (event) ->
    validateForm event

  $(document).on "submit", ".card-form", ->
    $(this).find(".submit").hide()
    $.fancybox.close()

  $(document).on "ajax:beforeSend", ".new-card, .edit-card", (xhr, data) ->
    $.fancybox.showLoading()

  $(document).on "ajax:success", ".new-card", (xhr, data) ->
    link = $(this)
    list = $(link.attr "data-list")
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      list.append $(data.html)
      markup()
      list.trigger "card-order-changed"
    .bind "ajax:complete", (xhr, data) -> 
      hideFormContainer()
    .bind "ajax:error", (xhr, status, error) -> 
      alert error.message

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    link = $(this)
    card = link.closest "li"
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      card.replaceWith data.html
      markup()
    .bind "ajax:complete", (xhr, data) -> 
      hideFormContainer()
    .bind "ajax:error", (event, xhr, status, error) ->
      alert error.message
  
  $(document).on "ajax:success", ".new-card, .edit-card", ->
    $.fancybox.open
      padding: 0
      href: "#card-form-container"

  $(document).on "ajax:success", ".delete-card", (xhr, data) ->
    link = $(this)
    card = link.closest "li"
    list = card.parent()
    card.remove()
    list.trigger "card-order-changed"
    markup()
    hideFormContainer()

  $(document).on "click", ".cancel-btn", (event) ->
    event.preventDefault()
    $.fancybox.close()

  markup = ->
    attachments = $(".attachment")
    for attachment in attachments
      markupid = attachment.getAttribute "data-markupid"
      title = attachment.getAttribute "data-title"
      content = attachment.getAttribute "data-content"
      link = attachment.getAttribute "data-link"
      url = content ? content : link
      $("a#" + markupid).attr "href", url
  markup()

  up = (state) ->
    previousState = state.prevAll ".state-wrapper:last"
    if previousState.length == 0
      return
    transition = state.next ".transition-wrapper"
    if transition.length != 0
      previousState.before transition
      transition.before state
    else 
      previousState.before state

  $(document).on "click", ".order-up-btn", (event) ->
    event.preventDefault()
    state = $(this).closest ".state-wrapper"
    up state

  $(document).on "click", ".order-down-btn", (event) ->
    event.preventDefault()
    state = $(this).closest ".state-wrapper"
    nextState = state.nextAll ".state-wrapper:first"
    if nextState.length == 0
      return
    up nextState

  $(document).on "click", ".order-change-btn", (event) ->
    event.preventDefault()
    $("#recipe-card-list").addClass "order-changing"

  $(document).on "click", ".order-commit-btn", (event) ->
    event.preventDefault()
    cards = getCards()
    forms = $(".fields .position")
    for form in forms
      form = $(form)
      id = form.attr "data-id"
      if $("#"+id).length == 0
        form.remove()

    numbering()
    for card in cards
      card = $(card)
      id = card.attr "id"
      position = parseInt card.attr("data-position")
      form = $(".position[data-id="+id+"]")
      if form.length == 0
        $("#add-card-order").click()
        form = $(".fields .position:last")
      form.val position

    $("#submit-card-order").click()
    $("#recipe-card-list").trigger "card-order-changed"

  getCards = ->  
    $(".card.state, .card.transition")

  numbering = ->
    cards = getCards()
    for card, index in cards
      $(card).attr "data-position", index + 1

  $(document).on "card-order-changed", "#recipe-card-list", (event) ->
    cards = getCards()
    previous = null
    position = 0
    new_transitions = []
    for card in cards
      position += 1        
      card = $(card)
      if previous and card.hasClass("state") and previous.hasClass("state") 
        new_transitions.push position
        position += 1
      previous = card
    numbering()
    for position in new_transitions
      $("#transition_move_to").val position
      $("#new_transition").submit()

  $(document).on "ajax:success", "#new_transition", (xhr, data) ->
    wrapper = $(data.html)
    card = wrapper.find ".card"
    position = parseInt card.attr("data-position")
    cards = getCards()
    target = $(cards[position - 1]).closest "li"
    wrapper.insertBefore target 
    numbering()
