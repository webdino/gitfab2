$ ->
  $(document).on "click", ".like-button", (e) ->
    e.preventDefault()
    like = $(e.target).parent ".like"
    like.find(".delete-like").val false
    button = like.find ".like-button"
    user = button.attr "data-user"
    if button.hasClass "liked"
      like.find(".delete-like." + user).val 1
    else
      if like.find("." + user).length > 0
        like.find("." + user).parent(".fields").remove()
      like.find(".add-like").click()
      liker_id_form = like.find ".like-form .liker_id:last"
      liker_id_form.val user
      liker_id_form.nextAll(".delete-like").addClass user
    like.find(".like-form").submit()

  $(document).on "ajax:beforeSend", ".like-form", (e) ->
    $(this).find("input:submit").attr "disabled", "disabled"

  $(document).on "ajax:success", ".like-form", (e) ->
    like = $(e.target).parent ".like"
    button = like.find ".like-button"
    number = parseInt button.text()
    if button.hasClass "liked"
      button.removeClass "liked"
      number -= 1
    else
      button.addClass "liked"
      number += 1
    button.text number
    $(this).find("input:submit").removeAttr "disabled"
