$ ->
  attachmentPlugin = MarkupPluginFactory.create(tinymce, {
    name: "attachment",
    tooltip: "link",
    kind: "link",
    icon: "link",
    width: 460,
    height: 200,
    tools: ["name", "link", "attachment"]
  })

  materialPlugin = MarkupPluginFactory.create(tinymce, {
    name: "material",
    tooltip: "material",
    kind: "material",
    icon: "link",
    width: 460,
    height: 300,
    tools: ["name", "link", "attachment", "description"]
  })

  toolPlugin = MarkupPluginFactory.create(tinymce, {
    name: "tool",
    tooltip: "tool",
    kind: "tool",
    icon: "link",
    width: 460,
    height: 300,
    tools: ["name", "link", "attachment", "description"]
  })

  blueprintPlugin = MarkupPluginFactory.create(tinymce, {
    name: "blueprint",
    tooltip: "blueprint",
    kind: "blueprint",
    icon: "link",
    width: 460,
    height: 300,
    tools: ["name", "link", "attachment", "description"]
  })

  $(document).on "card-attached", ".markup-form", (event, data) ->
    for markupform in $("#attachments .markup_id")
      if markupform.value == data.id
        fields = $(markupform).parent()
        break;
    if !fields
      $("#add-attachment").click()
      fields = $("#attachments .fields:last")

    fields.find(".title").val data.name
    fields.find(".url").val data.url
    fields.find(".description").val data.description
    fields.find(".markup_id").val data.id
    content = fields.find ".content"
    attach = $(data.attachmentElement)
    attach.attr "id", content.attr("id")
    attach.attr "name", content.attr("name")
    attach.addClass "content"
    fields.append attach
    content.remove()