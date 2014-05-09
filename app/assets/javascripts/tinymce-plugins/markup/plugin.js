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
        stateSelector: "a[href]"
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

      function createFileForm(label, name) {
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
        return containerElement;
      }

      function createImageForm(label, name, src) {
        var containerElement = $(document.createElement("div"));
        containerElement.addClass("container");
        containerElement.addClass(name);
        var labelElement = $(document.createElement("label"));
        labelElement.text(label);
        var inputElement = $(document.createElement("input"));
        inputElement.attr("type", "file");
        inputElement.attr("name", name);
        var imageElement = $(document.createElement("img"));
        if (!src || src.length == 0) {
          src = "/assets/fallback/noimage_240x180.png"
        }
        imageElement.attr("src", src);
        containerElement.append(labelElement);
        containerElement.append(inputElement);
        containerElement.append(imageElement);

        imageElement.click(function(e) {
          inputElement.trigger("click");
        });
        inputElement.change(function(e) {
          var target = e.target;
          var file = target.files[0];
          var reader = new FileReader();
          reader.onload = function() {
            imageElement.attr("src", reader.result);
          }
          reader.readAsDataURL(file);
        });
        return containerElement;
      }

      function createRadioForm(label, name, values, checkedValue) {
        var containerElement = $(document.createElement("div"));
        containerElement.addClass("container");
        containerElement.addClass(name);
        var labelElement = $(document.createElement("label"));
        labelElement.text(label);
        containerElement.append(labelElement);
        var groupElement = $(document.createElement("span"));
        for (var i = 0, n = values.length; i < n; i++) {
          var inputElement = $(document.createElement("input"));
          inputElement.attr("type", "radio");
          inputElement.attr("name", name);
          var value = values[i];
          inputElement.val(value);
          if (value == checkedValue) {

            inputElement.attr("checked", "checked");
          }
          groupElement.append(inputElement);
          groupElement.append($(document.createTextNode(value)));
        }
        containerElement.append(groupElement);
        return containerElement;
      }

      function createForm(data) {
        var formElement = $(document.createElement("form"));
        formElement.attr("id", "markup-form");
        formElement.append($(document.createElement("div")).text("link").addClass("link"));
        var urlElement = createTextForm("url", "url", data.url);
        urlElement.addClass("link-selection");
        formElement.append(urlElement);
        formElement.append($(document.createElement("div")).text("OR").addClass("center"));
        var attachmentElement = createFileForm("attachment", "attachment");
        attachmentElement.addClass("link-selection");
        formElement.append(attachmentElement);
        formElement.append($(document.createElement("hr")));
        var textElement = createTextForm("text", "text", data.text);
        formElement.append(textElement);
        formElement.append($(document.createElement("hr")));
        var imageElement = createImageForm("image", "image", data.image);
        formElement.append(imageElement);
        formElement.append($(document.createElement("hr")));
        var kindElement = createRadioForm("kind", "kind", ["link", "material", "tool", "blueprint"], data.kind);
        formElement.append(kindElement);
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

      function upload(action, type, file) {
        var formData = new FormData();
        formData.append("file", file);
        formData.append("utf8", "✓");
        formData.append("authenticity_token", getMetaContents("csrf-token"));
        formData.append("hint", editor.getParam("uploadimage_hint", ""));
        var deferred = new $.Deferred();
        $.ajax({
          url: action,
          type: "post",
          data: formData,
          processData: false,
          contentType: false,
          dataType: "json",
          complete: function(){},
          error: function(request, status, error) {
            var message = request.status + "\n" + status +"\n" + error.message;
            deferred.reject(message);
          },
          success: function(response) {
            response.type = type;
            deferred.resolve(response);
          }
        });
        return deferred.promise();
      }

      function showDialog() {
        var data = {};
        var selectedElement = editor.selection.getNode();
        var anchorElement = editor.dom.getParent(selectedElement, "a[href]");
        if (anchorElement) {
          data.anchor = anchorElement;
          data.text = $(anchorElement).text();
          data.url = editor.dom.getAttrib(anchorElement, "href");
          data.image = editor.dom.getAttrib(anchorElement, "data-image");
          data.kind = anchorElement.getAttribute("class");
        } else {
          data.text = editor.selection.getContent({format: "text"});
          data.url = "http://";
          data.kind = "link";
        }
        var form = createForm(data);
        var dialog = editor.windowManager.open({
          title: editor.translate(options.tooltip),
          width:  options.width,
          height:  options.height,
          buttons: [
            {
              text: editor.translate("Markup"),
              onclick: function() {
                var kind = $("#markup-form input[name=kind]:checked").val();
                var url = $("#markup-form input[name=url]").val();
                var text = $("#markup-form input[name=text]").val();
                var attachmentElement = $("#markup-form input[name=attachment]").get(0);
                var imageElement = $("#markup-form input[name=image]").get(0);
                var promises = []
                var uploadURL = editor.getParam("uploadimage_form_url", "/tinymce_assets");
                if (attachmentElement.files && attachmentElement.files.length != 0) {
                    promises.push(upload(uploadURL, "attachment", attachmentElement.files[0]));
                }
                if (imageElement.files && imageElement.files.length != 0) {
                    promises.push(upload(uploadURL, "image", imageElement.files[0]));
                }
                $.when.apply($, promises).done(function() {
                  var image = data.image || "";
                  for (var i = 0, n = arguments.length; i < n; i++) {
                    var updata = arguments[i];
                    if (updata.type == "image") {
                      image = updata.image.url;
                    } else if (updata.type == "attachment") {
                      //attachment is stronger than url
                      url = updata.image.url;
                    }
                  }
                  if (text.length == 0) {
                    if (url.length == 0 || url == "http://") {
                      editor.windowManager.close();
                      return;
                    }
                    text = url;
                  }
                  if (data.anchor) {
                    var anchor = $(data.anchor);
                    anchor.text(text);
                    anchor.attr("href", url);
                    anchor.attr("class", kind);
                    anchor.attr("data-image", image);
                  } else {
                    var html = "<a href=\""+url+"\" class=\""+kind+"\" data-image=\""+image+"\">";
                    html += text;
                    html += "</a>";            
                    editor.execCommand("mceInsertContent", false, html);
                  }
                  editor.windowManager.close();
                }).fail(function(e) {
                  alert(e);
                });
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
    return plugin;
  }

}