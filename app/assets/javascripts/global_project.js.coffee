$ ->
  $(document).on "click", ".show-all", (event) ->
    event.preventDefault()
    $(".selected-tags").css "display", "none"
    $(".all-tags").css "display", "block"

  $(document).on "click", ".show-selected", (event) ->
    event.preventDefault()
    $(".all-tags").css "display", "none"
    $(".selected-tags").css "display", "block"

$(window).on "load" , ->
  $(".projects").masonry
    itemSelector: ".project",
    "gutter": 20
