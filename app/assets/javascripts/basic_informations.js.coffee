$(".fancybox").fancybox
  openEffect: "none"
  closeEffect: "none"
  wrapCSS: ".fork-popup"
  helpers:
    overlay:
      css:
        "background": "rgba(0, 0, 0, 0.2)"

$(".change-owner-btn").fancybox
  openEffect: "none"
  closeEffect: "none"
  wrapCSS: ".fork-popup"
  helpers:
    overlay:
      css:
        "background": "rgba(0, 0, 0, 0.2)"

$("#add-collaborator-btn").fancybox
  openEffect: "none"
  closeEffect: "none"
  wrapCSS: ".fork-popup"
  helpers:
    overlay:
      css:
        "background": "rgba(0, 0, 0, 0.2)"
  #TODO: add the function to reload the .collabortors when close the fancybox

$(document).on "click", ".fork-btn", ->
  $(this).find("form").submit()

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

window.clearSelect2Value = () ->
  $("#s2id_user_name").select2 "val",""
  $("input#user_name").val ""
