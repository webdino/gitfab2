$ ->
  $(document).on "click", ".toggle-star-btn", ->
    $(this).html $(this).attr "data-label-on-click"
  $(document).on "ajax:success", ".toggle-star-btn", (e, data) ->
    $(this).replaceWith data.html
