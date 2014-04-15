$ ->
  $(document).on "click", ".toggle-star-btn", (e, data) ->
    $(this).html("...").attr "href", "javascript:void(0)"
  $(document).on "ajax:success", ".toggle-star-btn", (e, data) ->
    $(this).replaceWith data.html
