#= require jquery.colorbox
state_index_list = []

class Slideshow
  constructor: ->
    @button = $ "#slideshow-btn"
    @button.on "click", (event) =>
      event.preventDefault()
      @start()
  start: ->
    $(".card.state:not(:last) .slick-initialized").slick "unslick"
    states = $(".card.state:not(:last)").clone()
    $(".card.state:not(:last) .slick").slick
      adaptiveHeight: true
      dots: true
      infinite: true
      speed: 300
    states.find(".footer").remove()
    states.find(".new-card").remove()
    @cards = []
    @previous_state_num = 0
    state_index_list = []
    @split_annotations(state) for state in states
    @append_recipe_cards_list card for card in @cards
    @append_number card, i+1 for card, i in @cards
    @exchange_images card for card in @cards
    @enlarge_videos card for card in @cards
    _cards = @cards
    $.colorbox
      inline: true
      href: @cards
      rel: "slideshows"
      width: "100%"
      height: "100%"
      className: "slideshow"
      onComplete: () ->
        $("#cboxLoadedContent").slick
          adaptiveHeight: true
          dots: true
          infinite: true
          speed: 300
        $("#cboxLoadedContent figure .slick").slick
          dots: true
          infinite: true
          speed: 300
        setupDenominator _cards.length
        fixTextPosition()
        fixImagePosition()

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
      card.data "index", index
      state_index_list.push(index - 1)
    else
      number = $ document.createElement("div")
      number.addClass "number"
      number.html index
      card.append number
  append_recipe_cards_list: (card, index) ->
    card = $ card
    num = 0
    link_height_in_card_index = 15
    recipe_cards_list = $("#recipe-cards-list").clone()
    if card.children(".number").length > 0
      num = card.children(".number").html()
      @previous_state_num = num
    else
      num = @previous_state_num
    recipe_cards_list.find(".selector").css "margin-top", ((num - 1) * link_height_in_card_index + 1) + "px"
    card.append recipe_cards_list
  exchange_images: (card) ->
    card = $ card
    images = card.find "figure img"
    for image in images
      do (image) ->
        image = $ image
        original_src = image.attr "href"
        image.attr "src", original_src
  enlarge_videos: (card) ->
    card = $ card
    videos = card.find "figure iframe"
    for video in videos
      do (video) ->
        iframe = $ video
        iframe.css "width", "640px"
        iframe.css "height", "360px"
  setupDenominator = (cards_length) ->
    title = $("#basic-informations h1.title").clone()
    card = $ ".slideshow .card"
    card.append title
    denominator = $ document.createElement("div")
    denominator.html "/" + cards_length
    denominator.addClass "denominator"
    card.append denominator

  fixImagePosition = () ->
    slideshow = $ ".slideshow"
    figures = slideshow.find ".card figure"
    img = slideshow.find ".card figure > img"
    val = if img.css("display") == "block" then "inline-block" else "block"
    img.css "display", val
    for figure in figures
      do (figure) ->
        left =  (slideshow.width() - $(figure).width()) / 2
        $(figure).css "left", left

  fixTextPosition = () ->
    slideshow = $ ".slideshow"
    description = slideshow.find ".description.without-figures"
    top = (slideshow.height() - description.height()) / 2
    description.animate {
      "top", top
    }, 150

$ ->
  slideshow = new Slideshow()
  $(document).on "click", ".slideshow #recipe-cards-list .state-link", (event) ->
    event.preventDefault()
    index = $(this).parent().find(".state-link").index this
    $("#cboxLoadedContent").slick "slickGoTo", state_index_list[index]
