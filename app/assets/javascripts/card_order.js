$(function() {
  const up = function(cards) {
    let previousCard;
    if (cards.first().hasClass("state-wrapper")) {
      previousCard = cards.prev(".state-wrapper");
    } else {
      previousCard = cards.prev(".annotation-wrapper");
    }
    if (previousCard.length === 0) {
      return;
    }
    previousCard.before(cards);
  };

  $(document).on("click", ".order-up-btn", function(event) {
    event.preventDefault();
    const card = $(this).closest(".card-wrapper");
    if (card.hasClass("annotation-wrapper")) {
      const state = card.closest(".state-wrapper");
      state.addClass("annotation-order-changed");
    }
    up(card);
  });

  $(document).on("click", ".order-down-btn", function(event) {
    event.preventDefault();
    const card = $(this).closest(".card-wrapper");
    if (card.hasClass("state-wrapper")) {
      const nextStates = card.nextAll(".state-wrapper:first");
      if (nextStates.length > 0) {
        up(nextStates);
      }
    } else {
      const state = card.closest(".state-wrapper");
      state.addClass("annotation-order-changed");
      const nextAnnotations = card.nextAll(".annotation-wrapper:first");
      if (nextAnnotations.length > 0) {
        up(nextAnnotations);
      }
    }
  });

  $(document).on("click", ".order-change-btn", function(event) {
    event.preventDefault();
    $("#recipe-card-list").addClass("order-changing");
    $("#card-order-tools").addClass("order-changing");
  });

  $(document).on("click", ".order-commit-btn", function(event) {
    event.preventDefault();
    const states = $("#recipe-card-list .card.state");
    const forms = $(".edit_recipe .fields");
    forms.remove();
    for (let index = 0; index < states.length; index++) {
      let state = states[index];
      state = $(state);
      let id = state.attr("id");
      let position = index + 1;
      state.attr("data-position", position);
      $("#add-card-order").click();
      const field = $(".edit_recipe .fields:last");
      let positionForm = field.find(".position");
      positionForm.val(position);
      let idForm = field.find(".id");
      idForm.val(id);

      const state_wrapper = state.closest(".state-wrapper");
      if (state_wrapper.hasClass("annotation-order-changed")) {
        state_wrapper.removeClass("annotation-order-changed");
        const state_form = state.find(".edit_state .fields");
        state_form.remove();
        const annotations = state.find(".card.annotation");
        for (let annotation_index = 0; annotation_index < annotations.length; annotation_index++) {
          let annotation = annotations[annotation_index];
          annotation = $(annotation);
          id = annotation.attr("id");
          position = annotation_index + 1;
          annotation.attr("data-position", position);
          state.find(".add-annotation-order").click();
          const annotation_field = state.find(".fields:last");
          positionForm = annotation_field.find(".position");
          positionForm.val(position);
          idForm = annotation_field.find(".id");
          idForm.val(id);
          state.find(".submit-annotation-order").click();
        }
      }
    }

    $("#submit-card-order").click();
  });

  $(document).on("ajax:success", ".edit_recipe", function() {
    $("#recipe-card-list").removeClass("order-changing");
    $("#card-order-tools").removeClass("order-changing");
    $("#recipe-card-list").trigger("card-order-changed");
  });
});
