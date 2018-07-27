$(function() {
  $(document).on("ajax:success", "#new_collaboration", function(event, data) {
    $("#collaborations").append(data.html);
    clearSelect2Value();
  });

  $(document).on("click", ".remove-collaboration-btn", function(event) {
    event.preventDefault;
    $(this).closest("li").remove();
  });
});
