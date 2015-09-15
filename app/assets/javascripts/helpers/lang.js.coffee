getCookie = (name) ->
  result = null
  cookie_name = name + "="
  cookies = document.cookie
  position = cookies.indexOf cookie_name
  if position != -1
    start_index = position + cookie_name.length
    end_index = cookies.indexOf ";", start_index
    end_index = cookies.length if end_index == -1
    result = decodeURIComponent cookies.substring start_index, end_index
  return result

setCookie = (key, val, max_age_in_hour = null) ->
  update_cookie = key + "=" + encodeURIComponent(val) + "/;"
  update_cookie += " max-age=" + max_age_in_hour * 3600 if max_age_in_hour
  document.cookie = update_cookie

browserLanguage = ->
  try
    return (getCookie("lang") || navigator.browserLanguage || navigator.language || navigator.userLanguage).substr(0, 2)
  catch _error
    return undefined

$ ->
  lang = browserLanguage()
  if lang == "ja"
    $(".lang.en").removeClass "is-selected"
    $(".lang.jp").addClass "is-selected"
    $(".lang-en").css "display", "none"
    $(".lang-jp").css "display", "block"
  else
    $(".lang.en").addClass "is-selected"
    $(".lang.jp").removeClass "is-selected"
    $(".lang-jp").css "display", "none"
    $(".lang-en").css "display", "block"

  $(document).on "click", ".lang.en", (event) ->
    event.preventDefault()
    setCookie "lang", "en"
    unless $(this).hasClass "is-selected"
      $(this).addClass "is-selected"
      $(".lang.jp").removeClass "is-selected"
      $(".lang-jp").css "display", "none"
      $(".lang-en").css "display", "block"

  $(document).on "click", ".lang.jp", (event) ->
    event.preventDefault()
    setCookie "lang", "ja"
    unless $(this).hasClass "is-selected"
      $(this).addClass "is-selected"
      $(".lang.en").removeClass "is-selected"
      $(".lang-en").css "display", "none"
      $(".lang-jp").css "display", "block"
