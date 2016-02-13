$ ->
  url = $("#change-owner").data "url"
  $("#owner_name").select2 {
    width: "40%",
    placeholder: "Choose the new project owner",
    allowClear: true,
    ajax: {
      url: url,
      dataType: "json",
      cache: false,
      processResults: (data, params) ->
        ownerName = url.split("/")[1]
        return {
          results: $.map(data, (user, i) ->
            userName = user.name
            userSlug = user.slug
            if (userName isnt ownerName) and userName.indexOf(params.term) != -1
              return {id: userSlug, text: userName}
          )
        }
    }
  }

window.clearSelect2Value = () ->
  $("#s2id_owner_name").select2 "val",""
  $("input#owner_name").val ""
