$(function() {
  $(document).on("ajax:success", "#new_collaboration", function(event) {
    $("#collaborations").append(event.detail[0].html);
    clearSelect2Value();
  });

  $(document).on("click", ".remove-collaboration-btn", function(event) {
    event.preventDefault;
    $(this).closest("li").remove();
  });
});
