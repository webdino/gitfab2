$(function() {
  $(document).on("change", ".item-selection", function() {
    const value = $(this).find("option:selected").text();
    $(this).siblings(".item-name").val(value);
  });

  $(document).on("ajax:success", ".item-form", function(event) {
    const list = $(this).siblings(".items");
    list.append(event.detail[0].html);
  });

  $(document).on("ajax:success", ".feature-form", function(event) {
    const list = $(this).siblings(".features");
    list.append(event.detail[0].html);
  });

  $(document).on("click", ".remove-btn", function() {
    const li = $(this).closest("li");
    li.remove();
  });

  $(".item-selection").select2();
});
