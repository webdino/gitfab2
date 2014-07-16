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
    template = $(link.attr("data-template") + " > :first")
    className  = link.attr "data-classname"
    li = $ document.createElement("li")
    li.addClass "card-wrapper"
    li.addClass className
    card = null
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "submit", (e) ->
      card = template.clone()
      wait4save $(this), card
      li.append card
      list.append li
    .bind "ajax:success", (xhr, data) ->
      list.trigger "card-will-append", [li]
      card.replaceWith data.html
      list.trigger "card-appended", [li]
      adjustTransitionArrowHeight()
      markup()
    .bind "ajax:error", (xhr, status, error) ->
      li.remove()
      alert status

  $(document).on "ajax:success", ".edit-card", (xhr, data) ->
    link = $ this
    list = $(link.attr "data-list")
    li = $(this).closest "li"
    card = $(li).children().first()
    formContainer.html data.html
    $("form:first-child").parsley()
    formContainer.find "form"
    .bind "submit", (e) ->
      wait4save $(this), card
    .bind "ajax:success", (xhr, data) ->
      card.replaceWith data.html
      list.trigger "card-edited", [li]
      adjustTransitionArrowHeight()
      markup()
    .bind "ajax:error", (e, xhr, status, error) ->
      alert status

  $(document).on "card-will-delete", "#recipe-card-list", (event, li) -> 
    transition = li.next ".transition-wrapper"
    if transition.length is 1
      transition.find(".delete-transition").click()
    setStateIndex()

  $(document).on "card-appended", "#recipe-card-list", (event, li) -> 
    adjustArrowHeight li, "state"
    setStateIndex()
    if li.hasClass "state-wrapper"
      $("#new_transition").submit()

  $(document).on "card-edited", "#recipe-card-list", (event, li) ->
    adjustArrowHeight li, "state"
    setStateIndex()

  $(document).on "click", "#submit-card-order", (event) ->
    setStateIndex()

  $(document).on "ajax:success", "#new_transition", (xhr, data) ->
    wrapper = $ data.html
    card = wrapper.find ".card"
    li = $ document.createElement("li")
    li.addClass "card-wrapper"
    li.addClass "transition-wrapper"
    li.append wrapper
    $("#recipe-card-list").append li

  $(document).on "ajax:success", ".new-card, .edit-card", ->
    $.fancybox.open
      padding: 0
      href: "#card-form-container"
      afterLoad: ->
        setTimeout setupEditor, 100
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

  wait4save = (form, card) ->
    card.addClass "wait4save"
    title = form.find(".card-title").val()
    card.find(".title").text title
    link = form.find ".card-figure-link:first"
    if link.length is 1
      li = $ document.createElement("li")
      if link.val().length > 0
        #TODO youtube
        figure = link.val()
      else
        content = form.find ".card-figure-content:first"
        if content.get(0).files.length > 0
          figure = window.URL.createObjectURL content.get(0).files[0]
        else if content.val().length > 0
          figure = content.val()
        img = $ document.createElement("img")
        img.attr "src", figure
        li.append img
      ul = card.find "figure ul"
      ul.empty()
      ul.append li
    description = form.find(".card-description").val()
    card.find(".description").html description
    progress = $(document.createElement "progress")
    progress.attr "max", 1.0
    progress.attr "form", form.attr("id")
    card.find(".card-content").append progress
    form.bind "ajax:progress", (e, progressEvent) ->
      progress.attr "value", progressEvent.loaded / progressEvent.total

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