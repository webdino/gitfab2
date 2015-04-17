$ ->
  unless localStorage.getItem("fabble_maintenance_status") is "read"
    maintenance_notification = document.createElement "section"
    maintenance_notification.id = "layouts-maintenance-noticitaiton"
    inner = document.createElement "div"
    inner.className = "inner"
    $(inner).text "Server Maintenance : Night of April 19 - Noon of April 20 in Japan Time(UTC+9). Sorry for inconvenience."
    hide_btn = document.createElement "span"
    hide_btn.id = "hide-maintenance-notification"
    $(hide_btn).text "x"
    $(maintenance_notification).append $(inner).append(hide_btn)
    $("body").prepend maintenance_notification

  $(document).on "click", "#hide-maintenance-notification", () ->
      $("#layouts-maintenance-noticitaiton").css "display", "none"
      localStorage.setItem "fabble_maintenance_status", "read"
