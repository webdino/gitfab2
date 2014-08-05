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

setupEditor = ->
  editor = new nicEditor {
    buttonList: ["material", "tool", "blueprint", "attachment", "ol", "ul", "bold", "italic", "underline"]
  }
  editor.panelInstance "markup-area"

$ ->
  $.rails.ajax = (option) ->
    option.xhr =  ->
      xhr = $.ajaxSettings.xhr();
      form = $("form[action='" + option.url + "']")
      if form and xhr.upload
        xhr.upload.addEventListener "progress", (e) ->
          form.trigger "ajax:progress", [e]
      xhr
    $.ajax(option)

  formContainer = $ document.createElement("div")
  formContainer.attr "id", "card-form-container"
  formContainer.appendTo document.body

  $(document).on "ajax:error", ".new-card, .edit-card, .delete-card", (event, xhr, status, error) ->
    alert error.message
    event.preventDefault()

  $(document).on "click", ".card-form .submit", (event) ->
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
    template = $(link.attr("data-template") + " > :first")
    className  = link.attr "data-classname"
    li = $ document.createElement("li")
    li.addClass "card-wrapper"
    li.addClass className
    card = null
    formContainer.html data.html
    setupEditor()
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "submit", (e) ->
      card = template.clone()
      wait4save $(this), card
      li.append card
      list.append li
    .bind "ajax:success", (xhr, data) ->
      updateCard card, data
    .bind "ajax:error", (xhr, status, error) ->
      li.remove()
      alert status

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    link = $ this
    list = $(link.attr "data-list")
    li = $(this).closest "li"
    card = $(li).children().first()
    formContainer.html data.html
    setupEditor()
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "submit", (e) ->
      wait4save $(this), card
    .bind "ajax:success", (xhr, data) ->
      updateCard card, data
    .bind "ajax:error", (e, xhr, status, error) ->
      alert status

  $(document).on "ajax:success", ".new-card, .edit-card", ->
    $.fancybox.open
      padding: 0
      href: "#card-form-container"

  $(document).on "ajax:success", ".delete-card", (xhr, data) ->
    link = $ this
    li = link.closest "li"
    list = li.parent()
    li.remove()
    setStateIndex()
    markup()

  $(document).on "click", ".cancel-btn", (event) ->
    event.preventDefault()
    $.fancybox.close()

  $(document).on "card-order-changed", "#recipe-card-list", (event) ->
    setStateIndex()

  wait4save = (form, card) ->
    card.addClass "wait4save"
    card_content = card.find ".card-content:first"
    title = form.find(".card-title").val()
    card_content.find(".title").text title

    ul = card_content.find "figure ul"
    ul.empty()
    figures = form.find ".card-figure-content"
    for figure in figures
      if figure.files.length > 0
        src = window.URL.createObjectURL figure.files[0]
      else
        src = $(figure).val()
      img = $ document.createElement("img")
      img.attr "src", src
      li = $ document.createElement("li")
      li.append img
      ul.append li
    description = form.find(".card-description").val()
    card_content.find(".description").html description
    progress = $(document.createElement "progress")
    progress.attr "max", 1.0
    progress.attr "form", form.attr("id")
    card_content.append progress
    form.bind "ajax:progress", (e, progressEvent) ->
      progress.attr "value", progressEvent.loaded / progressEvent.total

  markup = ->
    attachments = $ ".attachment"
    for attachment in attachments
      markupid = attachment.getAttribute "data-markupid"
      content = attachment.getAttribute "data-content"
      if content && content.length > 0
        $("#" + markupid).attr "href", content
    $(document.body).trigger "attachment-markuped"
  markup()

  setStateIndex = ->
    states = $(".state-wrapper")
    states.each (index, element) ->
      $(element).find("h1.number").text index + 1
    if states.length > 1
      $(".order-change-btn").show()
    else
      $(".order-change-btn").hide()
  setStateIndex()

  setupFigureSlider = ->
    $('.flexslider').flexslider({
      animation: "slider",
      animationSpeed: 300,
      controlNav: true,
      smoothHeight: true,
      slideshow: false,
    })

  updateCard = (card, data) ->
    formContainer.empty()
    card.replaceWith data.html
    setStateIndex()
    markup()
    setupFigureSlider()
