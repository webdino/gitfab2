$ ->
  $("#note-card-list .description a").attr "target", "_blank"

  makeAttachmentsList = (attachments, container) ->
    ul = container.find "ul"
    ul.empty()
    attachments.attr "target", "_blank"
    if attachments.length is 0
      container.removeClass "has-data"
      $("#making-list .inner").removeClass "has-data"
      return
    container.addClass "has-data"
    $("#making-list .inner").addClass "has-data"
    for attachment in attachments
      href = attachment.getAttribute "href"
      description = attachment.getAttribute "data-description"
      name = attachment.textContent
      li = $ document.createElement("li")
      a = $ document.createElement("a")
      a.attr "href", href
      a.text name
      a.attr "alt", description
      a.attr "title", description
      a.attr "target", "_blank"
      li.append a
      ul.append li

  $(document).on "attachment-markuped", "", () ->
    makeAttachmentsList $("a.material"), $("#material-list")
    makeAttachmentsList $("a.tool"), $("#tool-list")
    makeAttachmentsList $("a.blueprint"), $("#blueprint-list")
    makeAttachmentsList $("a.attachment"), $("#references")

  $(document).on "click", "figure img", () ->
    $.fancybox.open $(this).data("src"),
      openEffect: "none"
      closeEffect: "none"
      helpers:
        overlay:
          css:
            "background": "rgba(0, 0, 0, 0.2)"

$(window).on "load" , ->
  $('.flexslider').flexslider({
    animation: "slider",
    animationSpeed: 300,
    controlNav: true,
    smoothHeight: true,
    slideshow: false,
  })
