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
      list.append li
      li.append $(data.html)
      list.trigger "card-order-changed"
    .bind "ajax:error", (xhr, status, error) ->
      alert error.message

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    card = $(this).closest("li").children().first()
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "ajax:success", (xhr, data) ->
      card.replaceWith data.html
    .bind "ajax:error", (event, xhr, status, error) ->
      alert error.message

  $(document).on "ajax:success", ".new-card, .edit-card", ->
    $.fancybox.open
      padding: 0
      href: "#card-form-container"
      afterLoad: ->
        setTimeout setupEditor, 4
      beforeClose: ->
        tinymce.remove()

  $(document).on "ajax:success", ".delete-card", (xhr, data) ->
    link = $ this
    card = link.closest "li"
    list = card.parent()
    card.remove()
    list.trigger "card-order-changed"

  $(document).on "click", ".cancel-btn", (event) ->
    event.preventDefault()
    $.fancybox.close()

  $(document).on "ajax:success", ".delete-card .new-card, .edit-card", (event) ->
    event.preventDefault()
    markup()

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
  markup()

  up = (state) ->
    previousState = state.prevAll ".state-wrapper:last"
    if previousState.length is 0
      return
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
    cards = getCards()
    forms = $ ".fields .position"
    for form in forms
      form = $ form
      id = form.attr "data-id"
      if $("#" + id).length is 0
        form.remove()

    numbering()
    for card in cards
      card = $ card
      id = card.attr "id"
      position = parseInt card.attr("data-position"), 10
      form = $(".position[data-id=" + id + "]")
      if form.length is 0
        $("#add-card-order").click()
        form = $ ".fields .position:last"
      form.val position

    $("#submit-card-order").click()
    $("#recipe-card-list").trigger "card-order-changed"

  getCards = ->
    $ ".card.state, .card.transition"

  numbering = ->
    cards = getCards()
    for card, index in cards
      $(card).attr "data-position", index + 1

  $(document).on "card-order-changed", "#recipe-card-list", (event) ->
    cards = getCards()
    previous = null
    position = 0
    newTransitions = []
    for card in cards
      position += 1
      card = $ card
      if previous and card.hasClass("state") and previous.hasClass("state")
        newTransitions.push position
        position += 1
      previous = card
    numbering()
    for position in newTransitions
      $("#transition_move_to").val position
      $("#new_transition").submit()

  $(document).on "ajax:success", "#new_transition", (xhr, data) ->
    wrapper = $ data.html
    card = wrapper.find ".card"
    position = parseInt card.attr "data-position"
    cards = getCards()
    target = $(cards[position - 1]).closest "li"
    li = $ document.createElement("li")
    li.addClass "card-wrapper"
    li.addClass "transition-wrapper"
    li.append wrapper
    li.insertBefore target
    numbering()
