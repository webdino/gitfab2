$(function() {
  $(".project-form").validate();
  $("#project_title").focus();

  $(document).on("change", "select#project_group_id", function() {
    $("#new_project").attr("action", $(this).val());
  });

  $(document).on("click", ".license img", function(event) {
    if ($(this).hasClass('unselectable')) {
      alert('You cannot choose this license because of Creative Commons license restriction of the original content.');
    } else {
      $(".license img").removeClass("selected");
      const target = $(this);
      target.addClass("selected");
      const value = target.attr("id").substring("license-".length);
      $("#project_license").val(value);
    }
  });

  $(document).on("submit", "#new_project.new_project", () => $('#loading-bar').show());
});
