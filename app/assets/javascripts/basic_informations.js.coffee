$(document).on "click", ".fork-btn", (event) ->
  event.preventDefault()
  form = $(this).find "form"
  form.submit()

$ ->
  search_term = null
  $("#collaborator_name").select2 {
    width: "40%",
    placeholder: "Choose a collaborator",
    allowClear: true,
    ajax: {
      url: "/owners.json",
      dataType: "json",
      cache: false,
      quietMillis: 250,
      data: (term, page) ->
        search_term = term
      results: (data, page) ->
        collaboratorsList = []
        ownerName = $("#owner > span:nth-child(2)").text()
        collaboratorsList.push ownerName
        $(".collaboration > span.name").each (index, element) ->
          collaboratorsList.push $(element).text()
        return {
          results: $.map(data, (collaborator, i) ->
            collaboratorName = collaborator.name
            collaboratorSlug = collaborator.slug
            if $.inArray(collaboratorName, collaboratorsList) == -1 and collaboratorName.indexOf(search_term) != -1
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

window.clearSelect2Value = () ->
  $("#s2id_user_name").select2 "val",""
  $("input#user_name").val ""
