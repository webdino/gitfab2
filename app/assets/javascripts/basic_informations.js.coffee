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
