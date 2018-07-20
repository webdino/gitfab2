const getCookie = function(name) {
  let result = null;
  const cookie_name = name + "=";
  const cookies = document.cookie;
  const position = cookies.indexOf(cookie_name);
  if (position !== -1) {
    const start_index = position + cookie_name.length;
    let end_index = cookies.indexOf(";", start_index);
    if (end_index === -1) { end_index = cookies.length; }
    result = decodeURIComponent(cookies.substring(start_index, end_index));
  }
  return result;
};

const setCookie = function(key, val, max_age_in_hour = null) {
  let update_cookie = key + "=" + encodeURIComponent(val) + "/;";
  if (max_age_in_hour) { update_cookie += ` max-age=${max_age_in_hour * 3600}`; }
  document.cookie = update_cookie;
};

const browserLanguage = function() {
  try {
    return (getCookie("lang") || navigator.browserLanguage || navigator.language || navigator.userLanguage).substr(0, 2);
  } catch (_error) {
    return undefined;
  }
};

$(function() {
  const lang = browserLanguage();
  if (lang === "ja") {
    $(".lang.en").removeClass("is-selected");
    $(".lang.jp").addClass("is-selected");
    $(".lang-en").css("display", "none");
    $(".lang-jp").css("display", "block");
  } else {
    $(".lang.en").addClass("is-selected");
    $(".lang.jp").removeClass("is-selected");
    $(".lang-jp").css("display", "none");
    $(".lang-en").css("display", "block");
  }

  $(document).on("click", ".lang.en", function(event) {
    event.preventDefault();
    setCookie("lang", "en");
    if (!$(this).hasClass("is-selected")) {
      $(this).addClass("is-selected");
      $(".lang.jp").removeClass("is-selected");
      $(".lang-jp").css("display", "none");
      $(".lang-en").css("display", "block");
    }
  });

  $(document).on("click", ".lang.jp", function(event) {
    event.preventDefault();
    setCookie("lang", "ja");
    if (!$(this).hasClass("is-selected")) {
      $(this).addClass("is-selected");
      $(".lang.en").removeClass("is-selected");
      $(".lang-en").css("display", "none");
      $(".lang-jp").css("display", "block");
    }
  });
});
