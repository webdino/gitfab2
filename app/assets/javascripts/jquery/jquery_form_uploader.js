(function($) {
  $.ajaxPrefilter(function(options, origOptions, jqXHR) {
    if (options.fileuploadform) {
      return "json";
    }
  });

  $.ajaxTransport("json", function(options, origOptions, jqXHR) { 
    if (!options.fileuploadform) {
      return false;
    }
    if ( !options.crossDomain || support.cors ) {
      var callback;
      return {
        send: function( headers, complete ) {
          var i;
          xhr = options.xhr();
          xhr.open( options.type, options.url, options.async, options.username, options.password );
          if ( options.xhrFields ) {
            for ( i in options.xhrFields ) {
              xhr[ i ] = options.xhrFields[ i ];
            }
          }
          if ( options.mimeType && xhr.overrideMimeType ) {
            xhr.overrideMimeType( options.mimeType );
          }
          if ( !options.crossDomain && !headers["X-Requested-With"] ) {
            headers["X-Requested-With"] = "XMLHttpRequest";
          }
          for ( i in headers ) {
            if ( headers[ i ] !== undefined ) {
              if (i == "Content-Type") {
                continue;
              }
              xhr.setRequestHeader( i, headers[ i ] + "" );
            }
          }
          xhr.send(options.data);

          callback = function( _, isAbort ) {
            var status, statusText, responses;
            if ( callback && ( isAbort || xhr.readyState === 4 ) ) {
              callback = undefined;
              xhr.onreadystatechange = jQuery.noop;
              if ( isAbort ) {
                if ( xhr.readyState !== 4 ) {
                  xhr.abort();
                }
              } else {
                responses = {};
                status = xhr.status;
                if ( typeof xhr.responseText === "string" ) {
                  responses.text = xhr.responseText;
                }
                try {
                  statusText = xhr.statusText;
                } catch( e ) {
                  statusText = "";
                }
                if ( !status && options.isLocal && !options.crossDomain ) {
                  status = responses.text ? 200 : 404;
                } else if ( status === 1223 ) {
                  status = 204;
                }
              }
            }

            if ( responses ) {
              complete( status, statusText, responses, xhr.getAllResponseHeaders() );
            }
          };

          if ( !options.async ) {
            callback();
          } else if ( xhr.readyState === 4 ) {
            setTimeout( callback );
          } else {
            xhr.onreadystatechange = callback;
          }
        },
        abort: function() {
          if ( callback ) {
            callback( undefined, true );
          }
        }
      }
    }
  });

  $(document).on("ajax:aborted:file", "form", function() {
    form = $(this);
    form.bind("ajax:beforeSend", function(event){
      const options = event.detail[1];
      options.fileuploadform = true;
      options.data = new FormData(this);
    });
    $.rails.handleRemote(form);
    return false;
  });
})(jQuery);
