$ ->

  markupPlugin = MarkupPluginFactory.create(tinymce, {
    name: "markup",
    tooltip: "link",
    kind: "link",
    icon: "link",
    width: 460,
    height: 200,
    tools: ["link", "text"]
  })

  attachmentPlugin = MarkupPluginFactory.create(tinymce, {
    name: "attachment",
    tooltip: "link",
    kind: "link",
    icon: "link",
    width: 460,
    height: 200,
    tools: ["link", "attachment", "text"]
  })

  materialPlugin = MarkupPluginFactory.create(tinymce, {
    name: "material",
    tooltip: "material",
    kind: "material",
    icon: "link",
    width: 460,
    height: 400,
    tools: ["link", "attachment", "text", "image", "description"]
  })

  toolPlugin = MarkupPluginFactory.create(tinymce, {
    name: "tool",
    tooltip: "tool",
    kind: "tool",
    icon: "link",
    width: 460,
    height: 400,
    tools: ["link", "attachment", "text", "image", "description"]
  })

  blueprintPlugin = MarkupPluginFactory.create(tinymce, {
    name: "blueprint",
    tooltip: "blueprint",
    kind: "blueprint",
    icon: "link",
    width: 460,
    height: 400,
    tools: ["link", "attachment", "text", "image", "description"]
  })

  installTinyMCE = (type, selector) ->
    if type is "status-textarea"
      tools = "material blueprint attachment unlink | bullist numlist"
      plugins = "autolink attachment material blueprint link paste"
    else if type is "way-textarea"
      tools = "tool blueprint attachment unlink | bullist numlist"
      plugins = "autolink attachment tool blueprint link paste"
    else if type is "attachment-textarea"
      tools = "tool blueprint attachment unlink | bullist numlist"
      plugins = "autolink attachment tool blueprint link paste"
    else
      tools = "markup unlink | bullist numlist"
      plugins = "autolink link markup paste"

    tinymce.init
      mode : "textareas"
      editor_selector: selector
      theme: "modern"
      menubar : false
      convert_urls : false
      toolbar1: tools
      image_advtab: true
      statusbar: false
      toolbar_items_size: "small"
      content_css: $("#markup-help").attr("data-css-path"),
      plugins: plugins
      setup: (editor) ->
        if $("#" + editor.id).hasClass "readonly"
          editor.settings.readonly = true 
          return

        editor.on "focus", (e) ->
          toolbar = $(e.target.contentAreaContainer.parentNode).find ".mce-toolbar-grp"
          toolbar.css "visibility", "visible"
        editor.on "blur", (e) ->
          toolbar = $(e.target.contentAreaContainer.parentNode).find ".mce-toolbar-grp"
          toolbar.css "visibility", "hidden"

        editor.on "init", ->
          editor.setContent $("#" + editor.id).text()

      paste_preprocess: (plugin, args) ->
        element = $(document.createElement "div")
        element.html args.content
        element.find("[style]").removeAttr "style"
        element.find("[class]").removeAttr "class"
        element.find("[id]").removeAttr "id"
        args.content = element.get(0).innerHTML

  textareaTypes = ["status-textarea", "way-textarea", "link-textarea", "attachment-textarea"]
  for type in textareaTypes
    installTinyMCE type, type

  $(document).on "tinymcize", ->
    textarea = $(this).find ".description-field"
    id = textarea.attr "id"
    for type in textareaTypes
      if textarea.hasClass type
        selector = id + type
        textarea.addClass selector
        installTinyMCE type, selector
        break
