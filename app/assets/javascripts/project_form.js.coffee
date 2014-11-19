$ ->
  $(".project-form").validate()

  $(document).on "submit", ".project-form", ->
    action = $("#project_owner_id").val()
    $(".project-form").attr "action", action

  $(document).on "change", "select#project_group_id", ->
    $("#new_project").attr "action", $(this).val()

  $("#delete-btn").click ->
    confirm "Are you sure to remove this project?"

  disableSubmitButtonForProject = ->
    $("#recipes-edit .caution").show()
    $("#recipes-edit iframe").attr "src", ""
    $("#recipes-edit .submit").attr "disabled", true

  YOUTUBE_URL_MIN_LENGTH   = 41
  YOUTUBE_EMBED_URL_BASE   = "http://www.youtube.com/embed/"
  # TODO: constantize '11'
  YOUTUBE_WATCH_URL_REGEXP = /https?:\/\/(?:www\.)?youtube.com\/watch\?v=([^&]{11,})(&\S*)?$/
  VIDEOID_MATCH_INDEX      = 1

  getVideoForProject = ->
    url = $(this).val()
    if previous_url != url
      previous_url = url
      if url.length > YOUTUBE_URL_MIN_LENGTH
        if matched = url.match YOUTUBE_WATCH_URL_REGEXP
          video_id_for_card = matched[VIDEOID_MATCH_INDEX]
          embed_url = YOUTUBE_EMBED_URL_BASE + video_id_for_card
          $(this).siblings("iframe").attr "src", embed_url
          $(this).siblings(".caution").hide()
          $("main#recipes-edit").find(".submit").attr "disabled", false
        else
          $("main#recipes-edit .caution").text "Invalid YouTube URL"
          disableSubmitButtonForItems()
      else
        $("main#recipes-edit .caution").text "URL is too short. URL length = #{url.length}. Min length = 42."
        disableSubmitButtonForItems()

  $(document).on "click", "#recipes-new .submit", (event) ->
    event.preventDefault()
    $("form.project-form").submit()

  $(document).on "click", "main#recipes-edit .submit", (event) ->
    url = $(".card-figure-link:visible").last().val()
    if url
      event.preventDefault()
      matched = url.match YOUTUBE_WATCH_URL_REGEXP
      video_id_for_card = matched[VIDEOID_MATCH_INDEX]
      embed_url = YOUTUBE_EMBED_URL_BASE + video_id_for_card
      $(".card-figure-link").last().val embed_url
      $("form.project-form").submit()

  $(document).on "click", "#project-summary .edit.btn", (event) ->
    $(event.target).parents(".btns").siblings(".card-figure-content").trigger "click"

  $(document).on "keyup", "main#recipes-edit .card-figure-link", getVideoForProject
  $(document).on "change", "main#recipes-edit .card-figure-link", getVideoForProject

  $(document).on "click", ".license img", (event) ->
    $(".license img").removeClass "selected"
    target = $ this
    target.addClass "selected"
    value = target.attr("id").substring "license-".length
    $("#project_license").val value
