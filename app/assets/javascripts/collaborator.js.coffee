$ ->
  $(document).on "ajax:success", "#new_collaboration", (event, data) ->
    $("#collaborations").append data.html
    clearSelect2Value()

  $(document).on "click", ".remove-collaboration-btn", (event) ->
    event.preventDefault
    $(this).closest("li").remove()
