$ ->
  $(".project-form").validate()
  $("#project_title").focus()

  $(document).on "submit", ".project-form", ->
    action = $("#project_owner_id").val()
    $(".project-form").attr "action", action

  $(document).on "change", "select#project_group_id", ->
    $("#new_project").attr "action", $(this).val()

  $("#delete-btn").click ->
    confirm "Are you sure to remove this project?"

  $(document).on "click", "#recipes-new .submit", (event) ->
    event.preventDefault()
    $("form.project-form").submit()

  $(document).on "click", ".license img", (event) ->
    $(".license img").removeClass "selected"
    target = $ this
    target.addClass "selected"
    value = target.attr("id").substring "license-".length
    $("#project_license").val value
