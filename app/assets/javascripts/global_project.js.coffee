$ ->
  $('.flexslider:not(:last)').flexslider
    animation: "slider",
    animationSpeed: 300,
    controlNav: true,
    smoothHeight: true,
    slideshow: false

  $('.flexslider:last').flexslider
    animation: "slider",
    animationSpeed: 300,
    controlNav: true,
    smoothHeight: true,
    slideshow: false,
    start: ->
      $("ul#featured-projects").packery
        itemSelector: ".project",
        gutter: 20
      $("ul#reciped-projects").packery
        itemSelector: ".project",
        gutter: 20
      return
