$ ->
  $(document).on "click", ".toggle-star-btn", (e, data) ->
    $(this).html "..."

  $(document).on "ajax:success", ".toggle-star-btn", (e, data) ->
    $(this).replaceWith data.html
