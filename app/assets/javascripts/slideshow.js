//= require jquery.colorbox
let state_index_list = [];

class Slideshow {
  start() {
    $(".card.state:not(:last) .slick-initialized").slick("unslick");
    const states = $(".card.state:not(:last)").clone();
    $(".card.state:not(:last) .slick").slick({
      adaptiveHeight: true,
      dots: true,
      infinite: true,
      speed: 300
    });
    states.find(".footer").remove();
    states.find(".new-card").remove();
    this.cards = [];
    this.previous_state_num = 0;
    state_index_list = [];
    for (let state of states) { this.split_annotations(state); }
    for (let card of this.cards) { this.append_recipe_cards_list(card); }
    for (let i = 0; i < this.cards.length; i++) { const card = this.cards[i]; this.append_number(card, i+1); }
    for (let card of this.cards) { this.exchange_images(card); }
    for (let card of this.cards) { this.enlarge_videos(card); }
    const _cards = this.cards;
    const setupDenominator = this.setupDenominator;
    const fixTextPosition = this.fixTextPosition;
    const fixImagePosition = this.fixImagePosition;
    $.colorbox({
      inline: true,
      href: this.cards,
      rel: "slideshows",
      width: "100%",
      height: "100%",
      className: "slideshow",
      onComplete() {
        $("#cboxLoadedContent").slick({
          adaptiveHeight: true,
          dots: true,
          infinite: true,
          speed: 300
        });
        $("#cboxLoadedContent figure .slick").slick({
          dots: true,
          infinite: true,
          speed: 300
        });
        setupDenominator(_cards.length);
        fixTextPosition();
        fixImagePosition();
      }
    });
  }

  split_annotations(state) {
    const annotations = $(state).find(".annotation");
    const annotation_list = annotations.clone();
    annotations.parents(".annotation-list").remove();
    this.cards.push(state);
    for (let annotation of annotation_list) this.cards.push(annotation)
  }
  append_number(card, index) {
    card = $(card);
    if (card.children(".number").length > 0) {
      card.children(".number").html(index);
      card.data("index", index);
      state_index_list.push(index - 1);
    } else {
      const number = $(document.createElement("div"));
      number.addClass("number");
      number.html(index);
      card.append(number);
    }
  }
  append_recipe_cards_list(card, index) {
    card = $(card);
    let num = 0;
    const link_height_in_card_index = 15;
    const recipe_cards_list = $("#recipe-cards-list").clone();
    if (card.children(".number").length > 0) {
      num = card.children(".number").html();
      this.previous_state_num = num;
    } else {
      num = this.previous_state_num;
    }
    recipe_cards_list.find(".selector").css("margin-top", (((num - 1) * link_height_in_card_index) + 1) + "px");
    card.append(recipe_cards_list);
  }
  exchange_images(card) {
    card = $(card);
    const images = card.find("figure img");
    for (let image of images) {
      {
        image = $(image);
        const original_src = image.attr("href");
        image.attr("src", original_src);
      }
    }
  }
  enlarge_videos(card) {
    card = $(card);
    const videos = card.find("figure iframe");
    for (let video of videos) {
      {
        const iframe = $(video);
        iframe.css("width", "640px");
        iframe.css("height", "360px");
      }
    }
  }
  setupDenominator(cards_length) {
    const title = $("#basic-informations h1.title").clone();
    const card = $(".slideshow .card");
    card.append(title);
    const denominator = $(document.createElement("div"));
    denominator.html(`/${cards_length}`);
    denominator.addClass("denominator");
    card.append(denominator);
  };
  fixImagePosition() {
    const slideshow = $(".slideshow");
    const figures = slideshow.find(".card figure");
    const img = slideshow.find(".card figure > img");
    const val = img.css("display") === "block" ? "inline-block" : "block";
    img.css("display", val);
    for (let figure of figures) {
      // Block-based scope instead of IIFE
      // https://github.com/DrkSephy/es6-cheatsheet#replacing-iifes-with-blocks
      {
        const left =  (slideshow.width() - $(figure).width()) / 2;
        $(figure).css("left", left);
      }
    }
  };
  fixTextPosition() {
    const slideshow = $(".slideshow");
    const description = slideshow.find(".description.without-figures");
    const top = (slideshow.height() - description.height()) / 2;
    description.animate({
      "top": "top", top
    }, 150);
  };
}

$(function() {
  const slideshow = new Slideshow();
  $(document).on("click", "#slideshow-btn", event => {
    event.preventDefault();
    slideshow.start();
  });
  $(document).on("click", ".slideshow #recipe-cards-list .state-link", function(event) {
    event.preventDefault();
    const index = $(this).parent().find(".state-link").index(this);
    $("#cboxLoadedContent").slick("slickGoTo", state_index_list[index]);
  });
});
