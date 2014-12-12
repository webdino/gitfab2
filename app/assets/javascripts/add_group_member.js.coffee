$ ->
  search_term = null
  $("#member_name").select2 {
    width: "40%",
    placeholder: "Choose a new member",
    allowClear: true,
    ajax: {
      url: "/users.json",
      dataType: "json",
      cache: false,
      data: (term, page) ->
        search_term = term
      results: (data, page) ->
        usersList = []
        $(".membership > .name").each (index, element) ->
          usersList.push $(element).text()
        return {
          results: $.map(data, (user, i) ->
            userName = user.name
            userSlug = user.slug
            if $.inArray(userName, usersList) == -1 and userName.indexOf(search_term) != -1
              return {id: userSlug, text: userName}
          )
        }
      }
  }

window.clearSelect2Value = () ->
  $("#s2id_member").select2 "val", ""
  $("input#membership_user_id").val ""
