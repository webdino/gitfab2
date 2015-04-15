$ ->
  $(document).on "change", ".item-selection", () ->
    value = $(this).find("option:selected").text()
    $(this).siblings(".item-name").val value

  $(document).on "ajax:success", ".item-form", (xhr, data) ->
    list = $(this).siblings ".items"
    list.append data.html

  $(document).on "ajax:success", ".feature-form", (xhr, data) ->
    list = $(this).siblings ".features"
    list.append data.html

  $(document).on "click", ".remove-btn", (xhr, data) ->
    li = $(this).closest "li"
    li.remove()
