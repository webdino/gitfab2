#= require fancybox

validateForm = (event) ->
  validated = false
  $(".card-form:first-child .validate").each (index, element) ->
    if $(element).val() != "" || $(element).text() != ""
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
  $(".nicEdit-main").addClass "validate"

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

  $(document).on "ajax:beforeSend", ".delete-card", ->
    confirm "Are you sure to remove this item?"

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

  $(document).on "click", ".add-image", (event) ->
    figure_list = $ "ul.figures"
    figures = figure_list.find ".figure"
    figures_length = figures.length
    last_figure = $(figures).last()
    iframe = figures.first().find "iframe"
    is_image_list = iframe.length == 0 or iframe.is ":hidden"
    if is_image_list
      last_figure.find(".card-figure-content").trigger "click"
    else if confirm "When you add an image, the youtube movie on this card will be removed. Are you sure?"
      removeAllFigures figures, figures_length
      last_figure.find(".card-figure-link").hide()
      last_figure.find(".card-figure-content").trigger "click"
    else
      event.preventDefault()

  $(document).on "click", ".add-video", (event) ->
    figure_list = $ "ul.figures"
    figures = figure_list.find ".figure"
    figures_length = figures.length
    if figures_length == 1 or confirm "When you add the youtube movie, the other images on this card will be removed. Are you sure?"
      removeAllFigures figures, figures_length
      last_figure = $(figures).last()
      last_figure.find("iframe").show()
      last_figure.find(".card-figure-link").show()
      last_figure.find(".edit").hide()
      last_figure.find("img").hide()
      figure_list.addClass "hide-add-buttons"
    else
      event.preventDefault()

  $(document).on "click", ".edit.btn", (event) ->
    $(event.target).siblings(".card-figure-content").trigger "click"

  $(document).on "click", ".remove_nested_fields", (event) ->
    figure_list = $ "ul.figures"
    figure_list.removeClass "hide-add-buttons"

  $(document).on "click", ".remove-all-figures", (event) ->
    figure_list = $ "ul.figures"
    figures = figure_list.find(".figure")
    figures.each (index, element) ->
      $(element).find(".delete.btn").find("a").trigger "click"
    figure_list.removeClass "hide-add-buttons"

  $(document).on "change", "input[type='file']", (event) ->
    file = event.target.files[0]
    reader = new FileReader()
    reader.onload = ->
      tmp_img = new Image
      tmp_img.src = reader.result
      $(event.target).siblings("img").attr "src", tmp_img.src
    reader.readAsDataURL file

  disableSubmitButtonForItems = ->
    $("#inner_content .caution").show()
    $("#inner_content iframe").attr "src", ""
    $("#inner_content .submit").attr "disabled", true

  removeAllFigures = (figures, length) ->
    figures.each (index, element) ->
      if index != length - 1
        $(element).find(".delete.btn").find("a").trigger "click"

  YOUTUBE_URL_MIN_LENGTH   = 41
  YOUTUBE_EMBED_URL_BASE   = "http://www.youtube.com/embed/"
  # TODO: constantize '11'
  YOUTUBE_WATCH_URL_REGEXP = /https?:\/\/(?:www\.)?youtube.com\/watch\?v=([^&]{11,})(&\S*)?$/
  VIDEOID_MATCH_INDEX      = 1

  getVideoForCard = ->
    url = $(this).val()
    if previous_url != url
      previous_url = url
      if url.length > YOUTUBE_URL_MIN_LENGTH
        if matched = url.match YOUTUBE_WATCH_URL_REGEXP
          video_id_for_card = matched[VIDEOID_MATCH_INDEX]
          embed_url = YOUTUBE_EMBED_URL_BASE + video_id_for_card
          $(this).siblings("iframe").attr "src", embed_url
          $(this).siblings(".caution").hide()
          $("#inner_content").find(".submit").attr "disabled", false
        else
          $("#inner_content .caution").text "Invalid YouTube URL"
          disableSubmitButtonForItems()
      else
        $("#inner_content .caution").text "URL is too short. URL length = #{url.length}. Min length = 42."
        disableSubmitButtonForItems()

  $(document).on "click", "#inner_content .submit", (event) ->
    url = $(".card-figure-link:visible").last().val()
    if url
      event.preventDefault()
      matched = url.match YOUTUBE_WATCH_URL_REGEXP
      video_id_for_card = matched[VIDEOID_MATCH_INDEX]
      embed_url = YOUTUBE_EMBED_URL_BASE + video_id_for_card
      $(".card-figure-link").last().val embed_url
      $(event.target).submit()

  $(document).on "keyup", "#inner_content .card-figure-link", getVideoForCard
  $(document).on "change", "#inner_content .card-figure-link", getVideoForCard

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

  setupFigureSlider = (selector) ->
    $(selector).flexslider {
      animation: "slider",
      animationSpeed: 300,
      controlNav: true,
      smoothHeight: true,
      slideshow: false,
    }

  updateCard = (card, data) ->
    formContainer.empty()
    article_id = $(data.html).find(".flexslider").closest("article").attr "id"
    selector = "#" + article_id + " .flexslider"
    card.replaceWith data.html
    setStateIndex()
    markup()
    setupFigureSlider selector
    if card.length is 0
      location.reload()
