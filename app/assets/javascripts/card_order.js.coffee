$ ->
  up = (cards) ->
    if cards.first().hasClass "state-wrapper"
      previousCard = cards.prev ".state-wrapper"
    else
      previousCard = cards.prev ".annotation-wrapper"
    if previousCard.length is 0
      return
    previousCard.before cards

  $(document).on "click", ".order-up-btn", (event) ->
    event.preventDefault()
    card = $(this).closest ".card-wrapper"
    if card.hasClass "annotation-wrapper"
      state = card.closest ".state-wrapper"
      state.addClass "annotation-order-changed"
    up card

  $(document).on "click", ".order-down-btn", (event) ->
    event.preventDefault()
    card = $(this).closest ".card-wrapper"
    if card.hasClass "state-wrapper"
      nextStates = card.nextAll ".state-wrapper:first"
      if nextStates.length > 0
        up nextStates
    else
      state = card.closest ".state-wrapper"
      state.addClass "annotation-order-changed"
      nextAnnotations = card.nextAll ".annotation-wrapper:first"
      if nextAnnotations.length > 0
        up nextAnnotations

  $(document).on "click", ".order-change-btn", (event) ->
    event.preventDefault()
    $("#recipe-card-list").addClass "order-changing"
    $("#card-order-tools").addClass "order-changing"

  $(document).on "click", ".order-commit-btn", (event) ->
    event.preventDefault()
    states = $ "#recipe-card-list .card.state"
    forms = $ ".edit_recipe .fields"
    forms.remove()
    for state, index in states
      state = $ state
      id = state.attr "id"
      position = index + 1
      state.attr "data-position", position
      $("#add-card-order").click()
      field = $ ".edit_recipe .fields:last"
      positionForm = field.find ".position"
      positionForm.val position
      idForm = field.find ".id"
      idForm.val id

      state_wrapper = state.closest ".state-wrapper"
      if state_wrapper.hasClass "annotation-order-changed"
        state_wrapper.removeClass "annotation-order-changed"
        state_form = state.find ".edit_state .fields"
        state_form.remove()
        annotations = state.find ".card.annotation"
        for annotation, annotation_index in annotations
          annotation = $ annotation
          id = annotation.attr "id"
          position = annotation_index + 1
          annotation.attr "data-position", position
          state.find(".add-annotation-order").click()
          annotation_field = state.find ".fields:last"
          positionForm = annotation_field.find ".position"
          positionForm.val position
          idForm = annotation_field.find ".id"
          idForm.val id
          state.find(".submit-annotation-order").click()

    $("#submit-card-order").click()

  $(document).on "ajax:success", ".edit_recipe", () ->
    $("#recipe-card-list").removeClass "order-changing"
    $("#card-order-tools").removeClass "order-changing"
    $("#recipe-card-list").trigger "card-order-changed"
