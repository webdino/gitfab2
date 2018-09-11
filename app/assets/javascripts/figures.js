$(function() {
  const YOUTUBE_URL_MIN_LENGTH = 28;
  const YOUTUBE_EMBED_URL_BASE = "https://www.youtube.com/embed/";
  const YOUTUBE_ID_LENGTH = 11;
  const YOUTUBE_WATCH_URL_REGEXP = new RegExp(`https?:\\/\\/(?:(?:youtu\\.be\\/)|(?:www\\.)?(?:youtube\\.com\\/watch\\?v=))([^&]{${YOUTUBE_ID_LENGTH},})(&\\S*)?$`);
  const VIDEOID_MATCH_INDEX = 1;

  const getVideoOf = function(object) {
    const id = object === "card" ? "#inner_content" : "main#recipes-edit";
    const url = $(".card-figure-link").last().val();
    let previous_url = undefined;
    if (previous_url !== url) {
      previous_url = url;
      if (url.length >= YOUTUBE_URL_MIN_LENGTH) {
        let matched;
        if (matched = url.match(YOUTUBE_WATCH_URL_REGEXP)) {
          const video_id = matched[VIDEOID_MATCH_INDEX];
          const embed_url = YOUTUBE_EMBED_URL_BASE + video_id;
          $(id).find("iframe").attr("src", embed_url);
          $(id).find(".caution").hide();
          $(id).find(".submit").attr("disabled", false);
        } else {
          $(id).find(".caution").text("Invalid YouTube URL");
          disableSubmitButtonOf(object);
        }
      } else {
        $(id).find(".caution").text(`URL is too short. URL length = ${url.length}. Min length = ${YOUTUBE_URL_MIN_LENGTH}.`);
        disableSubmitButtonOf(object);
      }
    }
  };

  const disableSubmitButtonOf = function(object) {
    const id = object === "card" ? "#inner_content" : "#recipes-edit";
    $(id).find(".caution").show();
    $(id).find("iframe").attr("src", "");
    $(id).find(".submit").attr("disabled", true);
  };

  const removeAllFigures = (figures, length) =>
    figures.each(function(index, element) {
      if (index !== (length - 1)) {
        $(element).find(".delete.btn").find("a").trigger("click");
      }
    });

  $(document).on("click", ".add-image", function(event) {
    const figure_list = $("ul.figures");
    const figures = figure_list.find(".figure");
    const figures_length = figures.length;
    const last_figure = $(figures).last();
    const iframe = figures.first().find("iframe");
    const is_image_list = (iframe.length === 0) || iframe.is(":hidden");
    if (is_image_list) {
      last_figure.find(".card-figure-content").trigger("click");
    } else if (confirm("When you add an image, the youtube movie on this card will be removed. Are you sure?")) {
      removeAllFigures(figures, figures_length);
      last_figure.find(".card-figure-link").hide();
      last_figure.find(".card-figure-content").trigger("click");
    } else {
      event.preventDefault();
    }
  });

  $(document).on("change", "input[type='file']", function(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = function() {
      const tmp_img = new Image;
      tmp_img.src = reader.result;
      $(event.target).siblings("img").attr("src", tmp_img.src);
    };
    reader.readAsDataURL(file);
  });

  $(document).on("click", ".add-video", function(event) {
    const figure_list = $("ul.figures");
    const figures = figure_list.find(".figure");
    const figures_length = figures.length;
    if ((figures_length === 1) || confirm("When you add the youtube movie, the other images on this card will be removed. Are you sure?")) {
      removeAllFigures(figures, figures_length);
      const last_figure = $(figures).last();
      last_figure.find("iframe").show();
      last_figure.find(".card-figure-link").show();
      last_figure.find(".edit").hide();
      last_figure.find("img").hide();
      figure_list.addClass("hide-add-buttons");
    } else {
      event.preventDefault();
    }
  });

  $(document).on("click", ".edit.btn", event => $(event.target).siblings(".card-figure-content").trigger("click"));

  $(document).on("click", "#project-summary .edit.btn", event => $(event.target).parents(".btns").siblings(".card-figure-content").trigger("click"));

  $(document).on("click", ".remove_nested_fields", function(event) {
    const figure_list = $("ul.figures");
    figure_list.removeClass("hide-add-buttons");
  });

  $(document).on("click", ".remove-all-figures", function(event) {
    const figure_list = $("ul.figures");
    const figures = figure_list.find(".figure");
    figures.each((index, element) => $(element).find(".delete.btn").find("a").trigger("click"));
    figure_list.removeClass("hide-add-buttons");
  });

  $(document).on("keyup change", "#inner_content .card-figure-link", () => getVideoOf("card"));

  $(document).on("keyup change", "main#recipes-edit .card-figure-link", () => getVideoOf("project"));
});
