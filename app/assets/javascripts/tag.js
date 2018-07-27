$(function() {
  $(document).on("ajax:success", ".delete-tag", function(xhr, data) {
    const link = $(this);
    const li = link.closest("li");
    li.remove();
  });

  $(document).on("ajax:success", "#tag-form", function(xhr, data) {
    const form = $(this);
    const ul = form.siblings(".tags");
    ul.append(data.html);
    const list = ul.find("li");
    if (list.length > 10) {
      const link = $(list.get(0)).find(".delete-tag");
      link.click();
    }
  });

  $(document).on("ajax:error", "#tag-form, .delete-tag", function(event, xhr, status, error) {
    alert(error.message);
    event.preventDefault();
  });

  $(document).on("click", "#show-tag-form", function(event) {
    $("#tag-form").show();
    $(this).hide();
    event.preventDefault();
  });
});
