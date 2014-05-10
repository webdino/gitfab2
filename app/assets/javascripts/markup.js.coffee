$(document).ready ->
  $(document).on "click", ".image-field", (event) ->
    event.preventDefault
    fileField = $(event.target.parentNode).find ".file-field"
    fileField.trigger "click"

  $(document).on "change", ".file-field", (event) ->
    target = event.target
    imageField = $(target.parentNode).find ".image-field"
    file = target.files[0]
    reader = new FileReader
    reader.onload = ->
      imageField.css "background-image", "url('#{reader.result}')"

    reader.readAsDataURL file

  markupPlugin = MarkupPluginFactory.create(tinymce, {
    name: "markup",
    tooltip: "link",
    kind: "link",
    icon: "link",
    width: 460,
    height: 200,
    tools: ["link", "text"]
  })

  materialPlugin = MarkupPluginFactory.create(tinymce, {
    name: "material",
    tooltip: "material",
    kind: "material",
    icon: "link",
    width: 460,
    height: 400,
    tools: ["link", "text", "image"]
  })

  toolPlugin = MarkupPluginFactory.create(tinymce, {
    name: "tool",
    tooltip: "tool",
    kind: "tool",
    icon: "link",
    width: 460,
    height: 400,
    tools: ["link", "text", "image"]
  })
  
  blueprintPlugin = MarkupPluginFactory.create(tinymce, {
    name: "blueprint",
    tooltip: "blueprint",
    kind: "blueprint",
    icon: "link",
    width: 460,
    height: 400,
    tools: ["link", "text", "image"]
  })

  installTinyMCE = (selector) ->
    if selector is "status-textarea"
      tools = "material blueprint markup unlink | bullist numlist"
      plugins = "autolink markup material blueprint link"
    else if selector is "way-textarea"
      tools = "tool blueprint markup unlink | bullist numlist"
      plugins = "autolink markup tool blueprint link"
    else
      tools = "markup unlink | bullist numlist"
      plugins = "autolink link markup"

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
      uploadimage_form_url: $("#markup-help").attr("data-upload-path")
      plugins: plugins
      setup: (editor) ->
        editor.on "focus", (e) ->
          toolbar = $(e.target.contentAreaContainer.parentNode).find ".mce-toolbar-grp"
          toolbar.css "visibility", "visible"
        editor.on "blur", (e) ->
          toolbar = $(e.target.contentAreaContainer.parentNode).find ".mce-toolbar-grp"
          toolbar.css "visibility", "hidden"

  textareaTypes = ["status-textarea", "way-textarea", "link-textarea"]
  for type in textareaTypes
    installTinyMCE type

  $(document).on "nested:fieldAdded", (event) ->
    textarea = event.field.find ".description-field"
    id = textarea.attr "id"
    for type in textareaTypes
      if textarea.hasClass type
        installTinyMCE type
        break

    tinymce.execCommand "mceAddEditor", false, id