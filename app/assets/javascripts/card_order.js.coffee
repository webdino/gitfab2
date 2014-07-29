$ ->
  up = (state) ->
    previousState = state.prev ".state-wrapper"
    if previousState.length is 0
      return
    previousState.before state

  $(document).on "click", ".order-up-btn", (event) ->
    event.preventDefault()
    state = $(this).closest ".state-wrapper"
    up state

  $(document).on "click", ".order-down-btn", (event) ->
    event.preventDefault()
    state = $(this).closest ".state-wrapper"
    nextStates = state.nextAll ".state-wrapper:first"
    if nextStates.length > 0
      up nextStates

  $(document).on "click", ".order-change-btn", (event) ->
    event.preventDefault()
    $("#recipe-card-list").addClass "order-changing"

  $(document).on "click", ".order-commit-btn", (event) ->
    event.preventDefault()
    cards = $ "#recipe-card-list .card.state, #recipe-card-list .card.transition"
    forms = $ ".edit_recipe .fields"
    forms.remove()
    for card, index in cards
      card = $ card
      id = card.attr "id"
      position = index + 1
      card.attr "data-position", position
      $("#add-card-order").click()
      field = $ ".edit_recipe .fields:last"
      positionForm = field.find ".position"
      positionForm.val position
      idForm = field.find ".id"
      idForm.val id
    $("#submit-card-order").click()

  $(document).on "ajax:success", ".edit_recipe", () ->
    $("#recipe-card-list").removeClass "order-changing"
    $("#recipe-card-list").trigger "card-order-changed"