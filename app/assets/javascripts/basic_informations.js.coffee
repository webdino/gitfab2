$(document).on "click", ".fork-btn", (event) ->
  event.preventDefault()
  form = $(this).find "form"
  form.submit()

$ ->
  $("#collaborator_name").select2 {
    width: "40%",
    placeholder: "Choose a collaborator",
    allowClear: true,
    ajax: {
      url: "/owners.json",
      dataType: "json",
      cache: false,
      delay: 250,
      processResults: (data, params) ->
        collaboratorsList = []
        ownerName = $("#owner > span:nth-child(2)").text()
        collaboratorsList.push ownerName
        $(".collaboration > span.name").each (index, element) ->
          collaboratorsList.push $(element).text()
        return {
          results: $.map(data, (collaborator, i) ->
            collaboratorName = collaborator.name
            collaboratorSlug = collaborator.slug
            if $.inArray(collaboratorName, collaboratorsList) == -1 && collaboratorName.indexOf(params.term) != -1
              return {id: collaboratorSlug, text: collaboratorName}
          )
        }
    }
  }

  $(".colorbox-link").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

  $(".change-owner-btn").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

  $("#add-collaborator-btn").colorbox
    inline: true
    width: "auto"
    height: "auto"
    className: "colorbox-bg-transparent"

$(document).on "click", ".select2-container", (event) ->
  $(".dropdown-wrapper").first().append $(".select2-dropdown").first()

$(document).on "click", ".select2-dropdown", (event) ->
  event.stopPropagation()

window.clearSelect2Value = () ->
  $("#s2id_user_name").select2 "val",""
  $("input#user_name").val ""
