$(function() {
  $(document).on("ajax:success", ".delete-tag", function() {
    const link = $(this);
    const li = link.closest("li");
    li.remove();
  });

  $(document).on("ajax:success", "#tag-form", function(event) {
    const form = $(this);
    const ul = form.siblings(".tags");
    ul.append(event.detail[0].html);
    const list = ul.find("li");
    if (list.length > 10) {
      const link = $(list.get(0)).find(".delete-tag");
      link.click();
    }
  });

  $(document).on("ajax:error", "#tag-form, .delete-tag", function(event) {
    alert(event.detail[0].message);
    event.preventDefault();
  });

  $(document).on("click", "#show-tag-form", function(event) {
    $("#tag-form").show();
    $(this).hide();
    event.preventDefault();
  });
});
