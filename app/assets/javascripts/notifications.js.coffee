$ ->
  $(document).on "ajax:success", ".show-notifications", (event, data, status) ->
    $("#notifications-index").replaceWith data.html

  $(document).click ->
    $("#notifications-index").addClass "hidden"

  $(document).on "click", "#notifications-index", (event) ->
    event.stopPropagation()

  $(document).on "click", "#notifications-index .notification .body", (event) ->
    url = $(this).data "url"
    $.ajax
      type: "PUT"
      url: url
      dataType: "json"

  $(document).on "click", "#notifications-index .mark-all-as-read", (event) ->
    url = $(this).data "url"
    $.ajax
      type: "GET"
      url: url
      dataType: "json"
      success: (data) ->
        $(".notifications-badge").hide()
      error: (data) ->
        alert data.message
