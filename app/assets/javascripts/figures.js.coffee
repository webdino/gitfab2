$ ->
  YOUTUBE_URL_MIN_LENGTH = 28
  YOUTUBE_EMBED_URL_BASE = "http://www.youtube.com/embed/"
  YOUTUBE_ID_LENGTH = 11
  YOUTUBE_WATCH_URL_REGEXP = ///https?:\/\/(?:(?:youtu\.be\/)|(?:www\.)?(?:youtube\.com\/watch\?v=))([^&]{#{YOUTUBE_ID_LENGTH},})(&\S*)?$///
  VIDEOID_MATCH_INDEX = 1

  embedVideo = (url) ->
    matched = url.match YOUTUBE_WATCH_URL_REGEXP
    video_id = matched[VIDEOID_MATCH_INDEX]
    embed_url = YOUTUBE_EMBED_URL_BASE + video_id
    $(".card-figure-link").last().val embed_url

  getVideoOf = (object) ->
    id = if object == "card" then "#inner_content" else "main#recipes-edit"
    url = $(".card-figure-link").val()
    if previous_url != url
      previous_url = url
      if url.length >= YOUTUBE_URL_MIN_LENGTH
        if matched = url.match YOUTUBE_WATCH_URL_REGEXP
          video_id = matched[VIDEOID_MATCH_INDEX]
          embed_url = YOUTUBE_EMBED_URL_BASE + video_id
          $(id).find("iframe").attr "src", embed_url
          $(id).find(".caution").hide()
          $(id).find(".submit").attr "disabled", false
        else
          $(id).find(".caution").text "Invalid YouTube URL"
          disableSubmitButtonOf object
      else
        $(id).find(".caution").text "URL is too short. URL length = #{url.length}. Min length = #{YOUTUBE_URL_MIN_LENGTH}."
        disableSubmitButtonOf object

  disableSubmitButtonOf = (object) ->
    id = if object == "card" then "#inner_content" else "#recipes-edit"
    $(id).find(".caution").show()
    $(id).find("iframe").attr "src", ""
    $(id).find(".submit").attr "disabled", true

  removeAllFigures = (figures, length) ->
    figures.each (index, element) ->
      if index != length - 1
        $(element).find(".delete.btn").find("a").trigger "click"

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

  $(document).on "click", "#project-summary .edit.btn", (event) ->
    $(event.target).parents(".btns").siblings(".card-figure-content").trigger "click"

  $(document).on "click", ".remove_nested_fields", (event) ->
    figure_list = $ "ul.figures"
    figure_list.removeClass "hide-add-buttons"

  $(document).on "click", ".remove-all-figures", (event) ->
    figure_list = $ "ul.figures"
    figures = figure_list.find(".figure")
    figures.each (index, element) ->
      $(element).find(".delete.btn").find("a").trigger "click"
    figure_list.removeClass "hide-add-buttons"

  $(document).on "click", "#inner_content .submit", (event) ->
    url = $(".card-figure-link:visible").last().val()
    if url
      event.preventDefault()
      embedVideo url
      $(event.target).submit()

  $(document).on "click", "main#recipes-edit .submit", (event) ->
    url = $(".card-figure-link:visible").last().val()
    if url
      event.preventDefault()
      embedVideo url
      $("form.project-form").submit()
    else
      event.preventDefault()
      $("form.project-form").submit()

  $(document).on "keyup", "#inner_content .card-figure-link", () ->
    getVideoOf("card")
  $(document).on "change", "#inner_content .card-figure-link", () ->
    getVideoOf("card")
  $(document).on "keyup", "main#recipes-edit .card-figure-link", () ->
    getVideoOf("project")
  $(document).on "change", "main#recipes-edit .card-figure-link", () ->
    getVideoOf("project")
