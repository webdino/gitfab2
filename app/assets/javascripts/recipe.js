$(function() {
  $("#note-card-list .description a").attr("target", "_blank");

  const makeAttachmentsList = function(attachments, container) {
    const ul = container.find("ul");
    ul.empty();
    attachments.attr("target", "_blank");
    const filtered_attachments = attachments.filter(function(i) {
      return this.textContent.replace(/[\n\s ]/g, "").length !== 0;
    });
    if (filtered_attachments.length === 0) {
      container.removeClass("has-data");
      $("#making-list .inner").removeClass("has-data");
      return
    }
    container.addClass("has-data");
    $("#making-list .inner").addClass("has-data");
    const result = [];
    [].forEach.call(filtered_attachments, (attachment) => {
      const href = attachment.getAttribute("href");
      const description = attachment.getAttribute("data-description");
      const name = attachment.textContent;
      const li = $(document.createElement("li"));
      const a = $(document.createElement("a"));
      a.attr("href", href);
      a.text(name);
      a.attr("alt", description);
      a.attr("title", description);
      a.attr("target", "_blank");
      li.append(a);
      result.push(ul.append(li));
    });
    return result;
  };

  $(document).on("attachment-markuped", "", function() {
    makeAttachmentsList($("a.material"), $("#material-list"));
    makeAttachmentsList($("a.tool"), $("#tool-list"));
    makeAttachmentsList($("a.blueprint"), $("#blueprint-list"));
    makeAttachmentsList($("a.attachment"), $("#references"));
  });
});
