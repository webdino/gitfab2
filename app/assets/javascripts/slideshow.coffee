#= require fancybox

class Slideshow
  constructor: ->
    @button = $ "#slideshow-btn"
    @button.on "click", (event) =>
      event.preventDefault()
      @start()
  start: ->
    states = $(".card.state:not(:last)").clone()
    states.find(".footer").remove()
    states.find(".new-card").remove()
    @cards = []
    @split_annotations(state) for state in states
    @append_number card, i+1 for card, i in @cards
    @exchange_images card for card in @cards
    _cards = @cards
    $.fancybox.open @cards, {
      padding: 0
      minWidth: "100%"
      minHeight: "100%"
      wrapCSS: "slideshow"
      afterLoad: (current, previous) ->
        setTimeout ->
          setupFlexSlider _cards.length
        , 100
      onUpdate: () ->
        setTimeout ->
          fixImagePosition()
        , 100
    }
  split_annotations: (state) ->
    annotations = $(state).find ".annotation"
    annotation_list = annotations.clone()
    annotations.parents(".annotation-list").remove()
    @cards.push state
    @cards.push(annotation) for annotation in annotation_list
  append_number: (card, index) ->
    card = $ card
    if card.children(".number").length > 0
      card.children(".number").html index
    else
      number = $ document.createElement("div")
      number.addClass "number"
      number.html index
      card.append number
  exchange_images: (card) ->
    card = $ card
    images = card.find "figure img"
    for image in images
      do (image) ->
        image = $ image
        original_src = image.data "src"
        image.attr "src", original_src
  setupFlexSlider = (cards_length) ->
    title = $("#basic-informations h1.title").clone()
    card = $ ".slideshow .card"
    card.append title
    denominator = $ document.createElement("div")
    denominator.html "/" + cards_length
    denominator.addClass "denominator"
    card.append denominator
    $(".flexslider").flexslider
      animation: "slider"
      animationSpeed: 300
      controlNav: true
      smoothHeight: true
      slideshow: true
      itemWidth: 0
      itemMargin: 0
  fixImagePosition = () ->
    slideshow = $ ".slideshow"
    figure = slideshow.find ".card figure"
    top = (slideshow.height() - figure.height()) / 2
    figure.animate {
      "top", top
    }, 100


$ ->
  slideshow = new Slideshow()
