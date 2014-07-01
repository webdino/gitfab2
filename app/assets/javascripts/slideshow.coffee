#= require fancybox

class Slideshow
  constructor: ->
    @button = $ '#slideshow-btn'
    @button.on 'click', (event) =>
      event.preventDefault()
      @start()
  start: ->
    cards = $('.card.state').clone()
    cards.find('footer').remove()
    $.fancybox.open cards, {
      padding: 24
      minWidth: '90%'
      minHeight: '90%'
    }

$ ->
  slideshow = new Slideshow()
