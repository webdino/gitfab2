$(() =>
  $("#member_name").select2({
    width: "40%",
    placeholder: "Choose a new member",
    allowClear: true,
    ajax: {
      url: "/users.json",
      dataType: "json",
      cache: false,
      processResults(data, params) {
        const usersList = [];
        $(".membership > .name > a").each((index, element) => usersList.push($(element).text()));
        return {
          results: $.map(data, function(user, i) {
            const userName = user.name;
            const userSlug = user.slug;
            if (($.inArray(userName, usersList) === -1) && (userName.indexOf(params.term) !== -1)) {
              return {id: userSlug, text: userName};
            }
          })
        };
      }
      }
  }));

window.clearSelect2Value = function() {
  $("#s2id_member").select2("val", "");
  $("input#membership_user_id").val("");
};
