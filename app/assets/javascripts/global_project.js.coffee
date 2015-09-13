$ ->
  $(document).on "click", ".lang.en", (event) ->
    event.preventDefault()
    unless $(this).hasClass "is-selected"
      $(this).addClass "is-selected"
      $(".lang.jp").removeClass "is-selected"
      $(".lang-jp").css "display", "none"
      $(".lang-en").css "display", "block"

  $(document).on "click", ".lang.jp", (event) ->
    event.preventDefault()
    unless $(this).hasClass "is-selected"
      $(this).addClass "is-selected"
      $(".lang.en").removeClass "is-selected"
      $(".lang-en").css "display", "none"
      $(".lang-jp").css "display", "block"

  $(document).on "click", ".show-all", (event) ->
    event.preventDefault()
    $(".selected-tags").css "display", "none"
    $(".all-tags").css "display", "block"

  $(document).on "click", ".show-selected", (event) ->
    event.preventDefault()
    $(".all-tags").css "display", "none"
    $(".selected-tags").css "display", "block"

$(window).on "load" , ->
  $(".projects").packery
    itemSelector: ".project",
    gutter: 20
