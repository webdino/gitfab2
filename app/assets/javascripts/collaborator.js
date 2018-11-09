$(function() {
  $(document).on("ajax:success", "#new_collaboration", function(event) {
    $("#collaborations").append(event.detail[0].html);
    $("#collaborator_name").val(null).trigger("change");
  });

  $(document).on("ajax:success", ".remove-collaboration-btn", function() {
    $(this).closest("li").remove();
  });
});
