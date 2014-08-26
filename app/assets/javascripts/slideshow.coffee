#= require fancybox

class Slideshow
  constructor: ->
    @button = $ "#slideshow-btn"
    @button.on "click", (event) =>
      event.preventDefault()
      @start()
  start: ->
    states = $(".card.state:not(:last)").clone()
    states.find("footer").remove()
    states.find(".new-card").remove()
    @cards = []
    @split_annotations(state) for state in states
    $.fancybox.open @cards, {
      padding: 0
      minWidth: "90%"
      minHeight: "90%"
      wrapCSS: "slideshow"
      afterLoad: (current, previous) ->
        setTimeout ->
          setupFlexSlider()
        , 100
    }
  split_annotations: (state) ->
    annotations = $(state).find ".annotation"
    annotation_list = annotations.clone()
    annotations.parents(".annotation-list").remove()
    @cards.push state
    @cards.push(annotation) for annotation in annotation_list
  setupFlexSlider = ->
    $(".flexslider").flexslider
      animation: "slider"
      animationSpeed: 300
      controlNav: true
      smoothHeight: true
      slideshow: true
      itemWidth: 0
      itemMargin: 0

$ ->
  slideshow = new Slideshow()
