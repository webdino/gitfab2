$(function() {
  const url = $("#change-owner").data("url");
  $("#owner_name").select2({
    width: "40%",
    placeholder: "Choose the new project owner",
    allowClear: true,
    ajax: {
      url,
      dataType: "json",
      cache: false,
      processResults(data, params) {
        const ownerName = url.split("/")[1];
        return {
          results: $.map(data, function(user, i) {
            const userName = user.name;
            const userSlug = user.slug;
            if ((userName !== ownerName) && (userName.indexOf(params.term) !== -1)) {
              return {id: userSlug, text: userName};
            }
          })
        };
      }
    }
  });
});

window.clearSelect2Value = function() {
  $("#s2id_owner_name").select2("val","");
  $("input#owner_name").val("");
};
