$(function() {
  $(document).on("change", ".item-selection", function() {
    const value = $(this).find("option:selected").text();
    $(this).siblings(".item-name").val(value);
  });

  $(document).on("ajax:success", ".item-form", function(xhr, data) {
    const list = $(this).siblings(".items");
    list.append(data.html);
  });

  $(document).on("ajax:success", ".feature-form", function(xhr, data) {
    const list = $(this).siblings(".features");
    list.append(data.html);
  });

  $(document).on("click", ".remove-btn", function(xhr, data) {
    const li = $(this).closest("li");
    li.remove();
  });

  $(".item-selection").select2();
});
