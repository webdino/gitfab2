$ ->
  makeAttachmentsList = (attachments, ul) ->
    ul.empty()
    attachments.attr "target", "_blank"
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
    makeAttachmentsList $("a.material"), $("#material-list ul")
    makeAttachmentsList $("a.tool"), $("#tool-list ul")
    makeAttachmentsList $("a.blueprint"), $("#blueprint-list ul")
