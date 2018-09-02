$(function() {
  $(document).on("ajax:success", "#new_collaboration", function(event) {
    $("#collaborations").append(event.detail[0].html);
    clearSelect2Value();
  });

  $(document).on("ajax:success", ".remove-collaboration-btn", function() {
    $(this).closest("li").remove();
  });
});
