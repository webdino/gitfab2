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

      function createForm(data, tools) {
        var formElement = $(document.createElement("form"));
        formElement.attr("id", "markup-form");
        var linkElement = $(document.createElement("div")).text("link");
        linkElement.addClass("link");
        linkElement.addClass("form-field");
        var urlElement = createTextForm("url", "url", data.url);
        urlElement.addClass("link-selection");
        linkElement.append(urlElement);
        var orElement = $(document.createElement("div")).text("OR").addClass("center");
        linkElement.append(orElement);
        var attachmentElement = createFileForm("attachment", "attachment");
        attachmentElement.addClass("link-selection");
        linkElement.append(attachmentElement);
        linkElement.addClass("form-field");
        formElement.append(linkElement);
        if (tools.indexOf("link") < 0) {
          linkElement.css("display", "none");
        }
        if (tools.indexOf("attachment") < 0) {
          orElement.css("display", "none");
          attachmentElement.css("display", "none");
        }
        var textElement = createTextForm("text", "text", data.text);
        textElement.addClass("form-field");
        formElement.append(textElement);
        if (tools.indexOf("text") < 0) {
          textElement.css("display", "none");
        }
        var imageElement = createImageForm("image", "image", data.image);
        imageElement.addClass("form-field");
        formElement.append(imageElement);
        if (tools.indexOf("image") < 0) {
          imageElement.css("display", "none");
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

      function upload(action, type, data) {
        var formData = new FormData();
        formData.append("file", data.file);
        formData.append("text", data.text);
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
          data.url = "";
          data.kind = "link";
        }
        var form = createForm(data, options.tools);
        var dialog = editor.windowManager.open({
          title: editor.translate(options.tooltip),
          width:  options.width,
          height:  options.height,
          buttons: [
            {
              text: editor.translate("Markup"),
              onclick: function() {
                var kind = options.kind;
                var url = $("#markup-form input[name=url]").val();
                var text = $("#markup-form input[name=text]").val();
                var attachmentElement = $("#markup-form input[name=attachment]").get(0);
                var imageElement = $("#markup-form input[name=image]").get(0);
                var promises = []
                var uploadURL = $("#markup-help").attr("data-" + kind + "-upload-path");
                if (attachmentElement.files && attachmentElement.files.length != 0) {
                    promises.push(upload(uploadURL, "attachment", {file: attachmentElement.files[0], text: text}));
                }
                if (imageElement.files && imageElement.files.length != 0) {
                    promises.push(upload(uploadURL, "image", {file: imageElement.files[0], text: text}));
                }
                $.when.apply($, promises).done(function() {
                  var image = data.image || "";
                  var item = null;
                  var itemType = null;
                  for (var i = 0, n = arguments.length; i < n; i++) {
                    var updata = arguments[i];
                    if (updata.type == "image") {
                      image = updata.image.url;
                    } else if (updata.type == "attachment") {
                      //attachment is stronger than url
                      url = updata.image.url;
                    }
                    item = updata.item;
                    itemType = updata.klass;
                  }
                  if (text.length == 0) {
                    if (url.length == 0) {
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
                    if (item) {
                      anchor.attr("data-item-id", item.id);
                    }
                  } else {
                    if (url.length < 1) {
                      url = image
                    }
                    var html = "<a " + 
                      "href='"           + url      + "' " +
                      "class='"          + kind     + "' " +
                      "data-item-id='"   + item.id  + "' " +
                      "data-item-type='" + itemType + "' " +
                      "data-image='"     + image    + "' " +
                      ">";
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
    tinymce.PluginManager.add(options.name, plugin);
    return plugin;
  }

}
