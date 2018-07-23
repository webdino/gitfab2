$(function() {
  const modalpane = $(document.createElement("div"));
  modalpane.attr("id", "modal-pane");
  $(document.body).append(modalpane);

  const is_safari = window.navigator.userAgent.toLowerCase().indexOf("safari") !== -1 ? true : false;

  const nicMarkupButton = nicEditorAdvancedButton.extend({
    width: 400,

    removePane() {
      modalpane.hide();
      if (this.pane) {
        this.pane.remove();
        this.pane = null;
        this.ne.selectedInstance.restoreRng();
      }
    },

    addPane() {
      $(".nicEdit-main").blur();
      modalpane.show();

      let container = new bkElement("div")
        .addClass("markup-form")
        .appendTo(this.pane.pane);

      container = $(container);

      const title = $(document.createElement("div"));
      title.text(this.type);
      container.append(title);

      container.append($(document.createElement("hr")));

      const nameInput = $(document.createElement("input"));
      nameInput.addClass("name");
      nameInput.attr("placeholder", this.type + " Name");
      container.append(nameInput);
      container.append($(document.createElement("hr")));

      const referenceContainer = $(document.createElement("div"));
      referenceContainer.addClass("reference");
      container.append(referenceContainer);

      const attachmentButton = $(document.createElement("a"));
      attachmentButton.addClass("attachment");
      attachmentButton.addClass("btn");
      attachmentButton.text("Attachment");
      referenceContainer.append(attachmentButton);
      attachmentButton.click(this.clickAttachment.closure(this));

      const fileInput = $(document.createElement("input"));
      fileInput.attr("type", "file");
      fileInput.addClass("file");
      container.append(fileInput);
      fileInput.change(this.selectFile.closure(this));

      const orLabel = $(document.createElement("label"));
      orLabel.text("or");
      orLabel.addClass("or");
      referenceContainer.append(orLabel);

      const urlInput = $(document.createElement("input"));
      urlInput.addClass("url");
      urlInput.attr("placeholder", "Reference URL");
      referenceContainer.append(urlInput);
      urlInput.change(this.selectURL.closure(this));

      const imageContainer = $(document.createElement("div"));
      imageContainer.addClass("imageContainer");
      container.append(imageContainer);

      const image = $(document.createElement("img"));
      image.addClass("image");
      imageContainer.append(image);

      const referenceLabel = $(document.createElement("label"));
      referenceLabel.addClass("reference-name");
      imageContainer.append(referenceLabel);

      container.append($(document.createElement("hr")));

      const markupButton = $(document.createElement("a"));
      markupButton.addClass("markup");
      markupButton.addClass("btn");
      markupButton.text("markup");
      container.append(markupButton);
      markupButton.click(this.clickMarkup.closure(this));

      const cancelButton = $(document.createElement("a"));
      cancelButton.addClass("cancel");
      cancelButton.addClass("btn");
      cancelButton.text("cancel");
      container.append(cancelButton);
      cancelButton.click(this.clickCancel.closure(this));

      this.container = container;

      const selectionText = $.selection();
      if (is_safari) {
        const sel_elm = this.ne.selectedInstance.selElm();
        if (sel_elm == null) {
          this.link = false;
        } else {
          this.link = sel_elm.parentTag("A");
        }
      } else {
        this.link = this.ne.selectedInstance.selElm().parentTag("A");
      }

      if (!this.link) {
        if (selectionText.length > 0) {
          nameInput.val(selectionText);
        }
      } else {
        let value = selectionText;
        if (selectionText.length < this.link.textContent.length) { value = this.link.textContent; }
        nameInput.val(value);
        let url = this.link.getAttribute("href");
        if (!url) { url = ""; }
        const attachment = this.link.getAttribute("data-attachment");
        if (attachment) {
          referenceLabel.text(attachment);
        } else {
          urlInput.val(url);
          referenceLabel.text(url);
        }
        this.showThumbnail(url);
      }

      const parent = $(this.pane.pane.parentNode);
      const w = $(window);
      const wOfWindow = w.width();
      const hOfWindow = w.height();
      const wOfPanel = parent.width();
      const hOfPanel = parent.height();
      const left = (wOfWindow - wOfPanel) / 2;
      const top = (hOfWindow - hOfPanel) / 2;
      parent.css({"position": "fixed", "top": top + "px", "left": left + "px"});
    },

    clickAttachment() {
      this.container.find(".file").click();
    },

    clickMarkup() {
      let file, id;
      const name = this.container.find(".name").val();
      if (name.length === 0) {
        alert(`Please Input ${this.type} Name`);
        return;
      }
      this.removePane();

      if (this.link) { id = this.link.getAttribute("id"); }
      if (!id) { id = this.uuid(); }

      let url = this.container.find(".url").val();
      if ((!url.match(/https?:\/\//)) && (url == null)) { url = `https://${url}`; }
      const fileInput = this.container.find(".file").get(0);
      if (fileInput.files.length > 0) { file = fileInput.files[0]; }

      const result = {id, kind: this.clazz, url, name, description: "", attachment: file, attachmentElement: fileInput};
      $(document).trigger("card-attached", result);

      if (!this.link) {
        const tmp = "#gitfab-temp-link";
        this.ne.nicCommand("createlink", tmp);
        this.link = this.findElm("A", "href", tmp);
      }

      const element = $(this.link || document.createElement("a"));
      element.attr("id", id);
      const previousAttachment = element.attr("data-attachment");

      if (file) {
        element.attr("href", file.url);
        element.attr("data-attachment", file.name);
      } else if (url.length > 0) {
        element.attr("href", url);
        element.removeAttr("data-attachment");
      } else if (previousAttachment) {
      } else {
        element.removeAttr("href");
      }

      element.attr("target", "_blank");
      element.attr("class", this.clazz);
      element.text(name);

      if (!this.link) {
        if (is_safari) {
          this.ne.selectedInstance.elm.appendChild(element.get(0));
        } else {
          this.ne.nicCommand("insertHTML", element.get(0).outerHTML);
        }
      }
    },

    clickCancel() {
      this.removePane();
    },

    selectFile() {
      const fileInput = this.container.find(".file").get(0);
      const file = fileInput.files[0];
      this.container.find(".reference-name").text(file.name);
      const reader = new FileReader();
      const image = this.container.find(".image");
      reader.onload = function() {
        file.url = reader.result;
        if (file.type.match(/^image\//)) {
          image.attr("src", reader.result);
        }
      };
      reader.readAsDataURL(file);
    },

    selectURL() {
      const url = this.container.find(".url").val();
      this.container.find(".reference-name").text(url);
      this.showThumbnail(url);
    },

    showThumbnail(url) {
      const image = this.container.find(".image");
      if (url.match(/^data:image/)) {
        image.attr("src", url);
      } else if (url.match(/^https?:\/\//)) {
        let thumbnailURL;
        if (url.match(/[.](jpe?g|png|gif|bmp)$/i)) {
          thumbnailURL = url;
        } else {
          thumbnailURL = `http://wimg.ca/w_100_h_100/${url}`;
        }
        image.attr("src", thumbnailURL);
      }
    },

    uuid() {
      const s = [];
      const hexDigits = "0123456789abcdef";
      for (let i = 0; i <= 35; i++) {
        s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
      }
      s[14] = "4";
      s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);
      s[8] = (s[13] = (s[18] = (s[23] = "-")));
      s.join("");
    }
  });

  window.nicMaterialButton = nicMarkupButton.extend({ type: "Material", clazz: "material" });
  window.nicToolButton = nicMarkupButton.extend({ type: "Tool", clazz: "tool" });
  window.nicBlueprintButton = nicMarkupButton.extend({ type: "Blueprint", clazz: "blueprint" });
  window.nicAttachmentButton = nicMarkupButton.extend({ type: "Attachment", clazz: "attachment" });
  const nicOptions = {
    buttons : {
      "material" : {name : "Material", type: "nicMaterialButton", tags : ["A"]},
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
  };
  nicEditors.registerPlugin(nicPlugin, nicOptions);

  $(document).on("card-attached", "", function(event, data) {
    let fields;
    for (let markupform of $("#attachments .markup_id")) {
      if (markupform.value === data.id) {
        fields = $(markupform).parent();
        break;
      }
    }
    if (!fields) {
      $("#add-attachment").click();
      fields = $("#attachments .fields:last");
    }

    fields.find(".title").val(data.name);
    fields.find(".link").val(data.url);
    fields.find(".description").val(data.description);
    fields.find(".kind").val(data.kind);
    fields.find(".markup_id").val(data.id);
    const content = fields.find(".content");
    const attach = $(data.attachmentElement);
    attach.attr("id", content.attr("id"));
    attach.attr("name", content.attr("name"));
    attach.addClass("content");
    fields.append(attach);
    content.remove();
  });
});
