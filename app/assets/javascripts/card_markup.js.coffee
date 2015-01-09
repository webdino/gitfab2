$ ->
  modalpane = $ document.createElement("div")
  modalpane.attr "id", "modal-pane"
  $(document.body).append modalpane

  nicMarkupButton = nicEditorAdvancedButton.extend {
    width: 400,

    removePane: ->
      modalpane.hide()
      if this.pane
        this.pane.remove()
        this.pane = null
        this.ne.selectedInstance.restoreRng()

    addPane: ->
      modalpane.show()

      container = new bkElement("div")
      .addClass("markup-form")
      .appendTo this.pane.pane

      container = $ container

      title = $ document.createElement("div")
      title.text this.type
      container.append title

      container.append $(document.createElement("hr"))

      nameInput = $ document.createElement("input")
      nameInput.addClass "name"
      nameInput.attr "placeholder", this.type + " Name"
      container.append nameInput
      container.append $(document.createElement("hr"))

      referenceContainer = $ document.createElement("div")
      referenceContainer.addClass "reference"
      container.append referenceContainer

      attachmentButton = $ document.createElement("a")
      attachmentButton.addClass "attachment"
      attachmentButton.addClass "btn"
      attachmentButton.text "Attachment"
      referenceContainer.append attachmentButton
      attachmentButton.click this.clickAttachment.closure(this)

      fileInput = $ document.createElement("input")
      fileInput.attr "type", "file"
      fileInput.addClass "file"
      container.append fileInput
      fileInput.change this.selectFile.closure(this)

      orLabel = $ document.createElement("label")
      orLabel.text "or"
      orLabel.addClass "or"
      referenceContainer.append orLabel

      urlInput = $ document.createElement("input")
      urlInput.addClass "url"
      urlInput.attr "placeholder", "Reference URL"
      referenceContainer.append urlInput
      urlInput.change this.selectURL.closure(this)

      imageContainer = $ document.createElement("div")
      imageContainer.addClass "imageContainer"
      container.append imageContainer

      image = $ document.createElement("img")
      image.addClass "image"
      imageContainer.append image

      referenceLabel = $ document.createElement("label")
      referenceLabel.addClass "reference-name"
      imageContainer.append referenceLabel

      container.append $(document.createElement("hr"))

      markupButton = $ document.createElement("a")
      markupButton.addClass "markup"
      markupButton.addClass "btn"
      markupButton.text "markup"
      container.append markupButton
      markupButton.click this.clickMarkup.closure(this)

      cancelButton = $ document.createElement("a")
      cancelButton.addClass "cancel"
      cancelButton.addClass "btn"
      cancelButton.text "cancel"
      container.append cancelButton
      cancelButton.click this.clickCancel.closure(this)

      this.container = container

      selectionText = $.selection()
      this.link = this.ne.selectedInstance.selElm().parentTag "A"
      unless this.link
        if selectionText.length > 0
          nameInput.val selectionText
      else
        value = selectionText
        value = this.link.textContent if selectionText.length < this.link.textContent.length
        nameInput.val value
        url = this.link.getAttribute "href"
        url = "" if !url
        attachment = this.link.getAttribute "data-attachment"
        if attachment
          referenceLabel.text attachment
        else
          urlInput.val url
          referenceLabel.text url
        this.showThumbnail url

      parent = $ this.pane.pane.parentNode
      w = $ window
      wOfWindow = w.width()
      hOfWindow = w.height()
      wOfPanel = parent.width()
      hOfPanel = parent.height()
      left = (wOfWindow - wOfPanel) / 2
      top = (hOfWindow - hOfPanel) / 2
      parent.css {"position": "fixed", "top": top + "px", "left": left + "px"}

    clickAttachment: ->
      this.container.find(".file").click()

    clickMarkup: ->
      name = this.container.find(".name").val()
      if name.length is 0
        alert "Please Input " + this.type + " Name"
        return
      this.removePane()

      id = this.link.getAttribute "id" if this.link
      id = this.uuid() if !id

      url = this.container.find(".url").val()
      fileInput = this.container.find(".file").get 0
      file = fileInput.files[0] if fileInput.files.length > 0

      result = {id: id, kind: this.clazz, url: url, name: name, description: "", attachment: file, attachmentElement: fileInput}
      $(document).trigger "card-attached", result

      unless this.link
        tmp = "#gitfab-temp-link"
        this.ne.nicCommand "createlink", tmp
        this.link = this.findElm "A", "href", tmp

      element = $ this.link || document.createElement("a")
      element.attr "id", id
      previousAttachment = element.attr "data-attachment"

      if file
        element.attr "href", file.url
        element.attr "data-attachment", file.name
      else if url.length > 0
        element.attr "href", url
        element.removeAttr "data-attachment"
      else if previousAttachment
      else
        element.removeAttr "href"

      element.attr "target", "_blank"
      element.attr "class", this.clazz
      element.text name

      unless this.link
        this.ne.nicCommand "insertHTML", element.get(0).outerHTML

    clickCancel: ->
      this.removePane()

    selectFile: ->
      fileInput = this.container.find(".file").get 0
      file = fileInput.files[0]
      this.container.find(".reference-name").text file.name
      reader = new FileReader()
      image = this.container.find ".image"
      reader.onload = ->
        file.url = reader.result
        if file.type.match /^image\//
          image.attr("src", reader.result)
      reader.readAsDataURL file

    selectURL: ->
      url = this.container.find(".url").val()
      this.container.find(".reference-name").text url
      this.showThumbnail url

    showThumbnail: (url) ->
      image = this.container.find ".image"
      if url.match /^data:image/
        image.attr "src", url
      else if url.match /^https?:\/\//
        if url.match /[.](jpe?g|png|gif|bmp)$/i
          thumbnailURL = url
        else
          thumbnailURL = "http://wimg.ca/w_100_h_100/" + url
        image.attr "src", thumbnailURL

    uuid: ->
      s = []
      hexDigits = "0123456789abcdef"
      for i in [0..35]
        s[i] = hexDigits.substr Math.floor(Math.random() * 0x10), 1
      s[14] = "4"
      s[19] = hexDigits.substr (s[19] & 0x3) | 0x8, 1
      s[8] = s[13] = s[18] = s[23] = "-"
      s.join ""
  }

  window.nicMaterialButton = nicMarkupButton.extend { type: "Material", clazz: "material" }
  window.nicToolButton = nicMarkupButton.extend { type: "Tool", clazz: "tool" }
  window.nicBlueprintButton = nicMarkupButton.extend { type: "Blueprint", clazz: "blueprint" }
  window.nicAttachmentButton = nicMarkupButton.extend { type: "Attachment", clazz: "attachment" }
  nicOptions = {
    buttons : {
      "material" : {name : "Matrial", type: "nicMaterialButton", tags : ["A"]},
      "tool" : {name : "Tool", type: "nicToolButton", tags : ["A"]},
      "blueprint" : {name : "Blueprint", type: "nicBlueprintButton", tags : ["A"]},
      "attachment" : {name : "Attachment or Link", type: "nicAttachmentButton", tags : ["A"]},
    },
    iconFiles : {
      "material" : "/images/material.png",
      "tool" : "/images/tool.png",
      "blueprint" : "/images/blueprint.png",
      "attachment" : "/images/attachment.png"
    }
  }
  nicEditors.registerPlugin nicPlugin, nicOptions

  $(document).on "card-attached", "", (event, data) ->
    for markupform in $("#attachments .markup_id")
      if markupform.value is data.id
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
