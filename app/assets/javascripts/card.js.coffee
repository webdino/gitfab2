#= require fancybox

validateForm = (event) ->
  validated = false
  $(".card-form:first-child .validate").each (index, element) ->
    if $(element).val() != ""
      validated = true
  unless validated
    alert "You cannot make empty card."
    event.preventDefault()

editor = null

tinymceSetting =
  selector: ".markup-area"
  theme: "modern"
  menubar: false
  convert_urls: false
  image_advtab: true
  statusbar: false
  toolbar_items_size: "small"
  content_css: $("#markup-help").attr "data-css-path"
  toolbar1: "bold italic forecolor backcolor fontsizeselect | bullist numlist | alignleft aligncenter alignright | hr | material tool blueprint attachment"
  plugins: [
    "attachment material tool blueprint autolink lists charmap hr anchor pagebreak searchreplace wordcount visualblocks visualchars code media nonbreaking contextmenu directionality paste textcolor uploadimage"
  ]
  setup: (currentEditor) ->
    editor = currentEditor
    editor.on "init", ->
      editor.setContent $("#" + editor.id).text()

setupEditor = ->
  tinymce.init tinymceSetting

$ ->
  formContainer = $ document.createElement("div")
  formContainer.attr "id", "card-form-container"
  formContainer.appendTo document.body

  setStateIndex = ->
    $(".state-wrapper").each (index, element) ->
      $(element).find("h1.number").text index + 1

  setStateIndex()

  adjustArrowHeight = (li, type) ->
    articleColumn = $(li).find ".article-column"
    firstColumn = $(li).find ".first-column"
    arrowBody = $(firstColumn).find ".arrow .body"
    height = articleColumn.css "height"
    if type is "state"
      firstColumn.css "height", height
      arrowBody.css "height", height
    else if type is "transition"
      height = (height.split("px")[0] - 18) + "px"
      firstColumn.css "height", height
      arrowBody.css "height", height
    image = articleColumn.find("figure").find("img").first()
    image.bind "load", () ->
      height = articleColumn.css "height"
      if type is "state"
        firstColumn.css "height", height
        arrowBody.css "height", height
      else if type is "transition"
        height = (height.split("px")[0] - 18) + "px"
        firstColumn.css "height", height
        arrowBody.css "height", height

  adjustStateArrowHeight = ->
    $(".state-wrapper").each (index, element) ->
      adjustArrowHeight element, "state"

  adjustTransitionArrowHeight = ->
    $(".transition-wrapper").each (index, element) ->
      adjustArrowHeight element, "transition"

  adjustStateArrowHeight()
  adjustTransitionArrowHeight()

  $(document).on "ajax:error", ".new-card, .edit-card, .delete-card", (event, xhr, status, error) ->
    alert error.message
    event.preventDefault()

  $(document).on "click", ".card-form .submit", (event) ->
    {selector} = tinymceSetting
    $(selector).text editor.getContent()
    validateForm event

  $(document).on "submit", ".card-form", ->
    submitButton = $(this).find ".submit"
    .off()
    .fadeTo 80, 0.01
    $.fancybox.close()

  $(document).on "ajax:beforeSend", ".new-card, .edit-card", $.fancybox.showLoading

  $(document).on "ajax:success", ".new-card", (xhr, data) ->
    link = $ this
    list = $(link.attr "data-list")
    formContainer.html data.html
    $("form:first-child").parsley()
    className  = $(link.attr "data-classname").selector
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      li = $ document.createElement("li")
      li.addClass "card-wrapper"
      li.addClass className
      li.append $(data.html)
      list.trigger "card-will-append", [li]
      list.append li
      list.trigger "card-appended", [li]
      adjustTransitionArrowHeight()
      markup()
    .bind "ajax:error", (xhr, status, error) ->
      alert error.message

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    link = $ this
    list = $(link.attr "data-list")
    li = $(this).closest "li"
    card = $(li).children().first()
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      card.replaceWith data.html
      list.trigger "card-edited", [li]
      adjustTransitionArrowHeight()
      markup()
    .bind "ajax:error", (event, xhr, status, error) ->
      alert error.message

  $(document).on "ajax:success", ".new-card, .edit-card", ->
    $.fancybox.open
      padding: 0
      href: "#card-form-container"
      afterLoad: ->
        setTimeout setupEditor, 50
      beforeClose: ->
        tinymce.remove()

  $(document).on "ajax:success", ".delete-card", (xhr, data) ->
    link = $ this
    li = link.closest "li"
    list = li.parent()
    list.trigger "card-will-delete", [li]
    li.remove()
    list.trigger "card-deleted", [li]
    adjustTransitionArrowHeight()
    markup()

  $(document).on "click", ".cancel-btn", (event) ->
    event.preventDefault()
    $.fancybox.close()

  markup = ->
    attachments = $ ".attachment"
    for attachment in attachments
      markupid = attachment.getAttribute "data-markupid"
      content = attachment.getAttribute "data-content"
      url = ""
      if content
        url = content
      else
        url = attachment.getAttribute "data-link"
      $("#" + markupid).attr "href", url
    $(document.body).trigger "attachment-markuped"
  markup()

  up = (state) ->
    previousTransition = state.prev ".transition-wrapper"
    if previousTransition.length is 0
      return
    previousState = previousTransition.prev()
    transition = state.next ".transition-wrapper"
    if transition.length > 0
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
    nextStates = state.nextAll ".state-wrapper:first"
    if nextStates.length > 0
      up nextStates

  $(document).on "click", ".order-change-btn", (event) ->
    event.preventDefault()
    $("#recipe-card-list").addClass "order-changing"

  $(document).on "click", ".order-commit-btn", (event) ->
    event.preventDefault()
    numbering()
    cards = getCards()
    forms = $ ".edit_recipe .fields"
    forms.remove()
    for card in cards
      card = $ card
      id = card.attr "id"
      position = parseInt card.attr("data-position"), 10
      $("#add-card-order").click()
      field = $ ".edit_recipe .fields:last"
      positionForm = field.find ".position"
      positionForm.val position
      idForm = field.find ".id"
      idForm.val id
    $("#submit-card-order").click()

  getCards = ->
    $ ".card.state, .card.transition"

  numbering = ->
    cards = getCards()
    for card, index in cards
      $(card).attr "data-position", index + 1

  $(document).on "card-appended", "#recipe-card-list", (event, li) ->
    adjustArrowHeight li, "state"
    setStateIndex()
    if li.hasClass "state-wrapper"
      $("#new_transition").submit()

  $(document).on "card-edited", "#recipe-card-list", (event, li) ->
    adjustArrowHeight li, "state"
    setStateIndex()

  $(document).on "card-will-delete", "#recipe-card-list", (event, li) ->
    transition = li.next ".transition-wrapper"
    if transition.length is 1
      transition.find(".delete-transition").click()
    setStateIndex()

  $(document).on "ajax:success", "#new_transition", (xhr, data) ->
    wrapper = $ data.html
    card = wrapper.find ".card"
    li = $ document.createElement("li")
    li.addClass "card-wrapper"
    li.addClass "transition-wrapper"
    li.append wrapper
    $("#recipe-card-list").append li

  $(document).on "ajax:success", ".edit_recipe", () ->
    $("#recipe-card-list").removeClass "order-changing"
