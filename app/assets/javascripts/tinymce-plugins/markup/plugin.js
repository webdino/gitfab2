/**
 * this program is forked from https://github.com/PerfectlyNormal/tinymce-rails-imageupload
 * MIT License
 */
var MarkupPluginFactory = {
  create: function(tinymce, options) {
    var plugin = function(editor, url) {
      editor.addButton(options.name, {
        tooltip: editor.translate(options.tooltip),
        icon : options.icon,
        onclick: showDialog,
        stateSelector: "a." + options.kind
      });

      function createTextForm(label, name, value) {
        var containerElement = $(document.createElement("div"));
        containerElement.addClass("container");
        containerElement.addClass(name);
        var labelElement = $(document.createElement("label"));
        labelElement.text(label);
        var inputElement = $(document.createElement("input"));
        inputElement.val(value);
        inputElement.attr("type", "text");
        inputElement.attr("name", name);
        containerElement.append(labelElement);
        containerElement.append(inputElement);
        return containerElement;
      }

      function createFileForm(label, name, value) {
        var containerElement = $(document.createElement("div"));
        containerElement.addClass("container");
        containerElement.addClass(name);
        var labelElement = $(document.createElement("label"));
        labelElement.text(label);
        var inputElement = $(document.createElement("input"));
        inputElement.attr("type", "file");
        inputElement.attr("name", name);
        containerElement.append(labelElement);
        containerElement.append(inputElement);
        if (value) {
          var valueElement = $(document.createElement("div"));
          valueElement.text(value);
          containerElement.addClass("value");
          containerElement.append(valueElement);
        }
        return containerElement;
      }

      function createTextAreaForm(label, name, value) {
        var containerElement = $(document.createElement("div"));
        containerElement.addClass("container");
        containerElement.addClass(name);
        var labelElement = $(document.createElement("label"));
        labelElement.text(label);
        var inputElement = $(document.createElement("textarea"));
        inputElement.val(value);
        inputElement.attr("name", name);
        containerElement.append(labelElement);
        containerElement.append(inputElement);
        return containerElement;
      }

      function createForm(id, data, tools) {
        var formElement = $(document.createElement("form"));
        formElement.attr("id", id);
        formElement.attr("class", "markup-form");

        var textElement = createTextForm("name", "name", data.name);
        textElement.addClass("form-field");
        formElement.append(textElement);
        if (tools.indexOf("name") < 0) {
          textElement.css("display", "none");
        }

        var attachmentElement = createFileForm("attachment", "attachment", data.attachment);
        attachmentElement.addClass("form-field");
        formElement.append(attachmentElement);
        if (tools.indexOf("attachment") < 0) {
          attachmentElement.css("display", "none");
        }

        if (tools.indexOf("link") >= 0 && tools.indexOf("attachment") >= 0) {
          var orElement = $(document.createElement("div")).text("OR").addClass("center");
          formElement.append(orElement);
        }

        var urlElement = createTextForm("url", "url", data.url);
        formElement.append(urlElement);
        if (tools.indexOf("link") < 0) {
          urlElement.css("display", "none");
        }

        var descriptionElement = createTextAreaForm("description", "description", data.description);
        descriptionElement.addClass("form-field");
        formElement.append(descriptionElement);
        if (tools.indexOf("description") < 0) {
          descriptionElement.css("display", "none");
        }
        return formElement;
      }

      function getMetaContents(mn) {
        var m = document.getElementsByTagName("meta");
        for(var i in m) {
          if(m[i].name == mn) {
            return m[i].content;
          }
        }
        return null;
      }

      function applyToDocument(editor, originalData, result) { 
        var anchor = originalData.anchor || document.createElement("a");
        anchor = $(anchor);
        anchor.attr("id", result.id);
        anchor.text(result.name);
        anchor.attr("href", result.url == "" ? "#" : result.url);
        anchor.attr("class", result.kind);
        if (result.attachment) {
          anchor.attr("data-attachment", result.attachment.name);
        }
        anchor.attr("data-description", result.description);
        if (!originalData.anchor) {
          editor.execCommand("mceInsertContent", false, anchor.get(0).outerHTML);
        }
      }

      function uuid() {
        var s = [];
        var hexDigits = "0123456789abcdef";
        for (var i = 0; i < 36; i++) {
          s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
        }
        s[14] = "4";
        s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);
        s[8] = s[13] = s[18] = s[23] = "-";
        return s.join("");
      }

      function showDialog() {
        var data = {};
        var selectedElement = editor.selection.getNode();
        var anchorElement = editor.dom.getParent(selectedElement, "a");
        if (anchorElement) {
          data.anchor = anchorElement;
          data.id = editor.dom.getAttrib(anchorElement, "id");;
          data.name = $(anchorElement).text();
          data.url = editor.dom.getAttrib(anchorElement, "href");
          data.kind = anchorElement.getAttribute("class");
          data.attachment = editor.dom.getAttrib(anchorElement, "data-attachment");
          data.description = editor.dom.getAttrib(anchorElement, "data-description");
        } else {
          data.name = editor.selection.getContent({format: "text"});
          data.url = "";
          data.kind = options.kind;
          data.description = "";
        }
        var formid = "markup-form-" + (new Date()).getTime();
        var form = createForm(formid, data, options.tools);
        var dialog = editor.windowManager.open({
          title: editor.translate(options.tooltip),
          width:  options.width,
          height:  options.height,
          buttons: [
            {
              text: editor.translate("Markup"),
              onclick: function() {
                var id = data.id || uuid();
                var kind = options.kind;
                var url = $("#" + formid + " input[name=url]").val();
                var name = $("#" + formid + " input[name=name]").val();
                var description = $("#" + formid + " textarea").val();
                var attachmentElement = $("#" + formid + " input[name=attachment]").get(0);
                var attachment = (attachmentElement.files && attachmentElement.files.length != 0) ? attachmentElement.files[0] : null;
                if (name == "" && url == "" && !attachment) {
                  editor.windowManager.close();
                  return;
                }
                var result = {id: id, kind: kind, url: url, name: name, description: description, attachment: attachment, attachmentElement: attachmentElement};
                applyToDocument(editor, data, result);
                $(form).trigger("card-attached", result);
                editor.windowManager.close();
              },
              subtype: "primary"
            },
            {
              text: editor.translate("Cancel"),
              onclick: editor.windowManager.close
            }
          ]
        }, {
          plugin_url: url
        });
        $(".mce-window-head + .mce-container-body").append(form);
      }
    }
    tinymce.PluginManager.add(options.name, plugin);
    return plugin;
  }

}
