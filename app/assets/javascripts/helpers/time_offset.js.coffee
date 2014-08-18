$ ->
  calculate_local_time = (date_object, time_offset_in_hours) ->
    date_text = date_object.text().split ", "
    if date_text[1] == undefined
      return
    date = date_text[0].split "-"
    time = date_text[1].split ":"
    new_date = new Date date[0] - 0, date[1] - 0, date[2] - 0, time[0] - 0, time[1] - 0, time[2] - 0
    new_date.setHours (time[0] - 0) + time_offset_in_hours

    month = if new_date.getMonth() < 10 then "0" + new_date.getMonth() else new_date.getMonth()
    day = if new_date.getDate() < 10 then "0" + new_date.getDate() else new_date.getDate()
    hours = if new_date.getHours() < 10 then "0" + new_date.getHours() else new_date.getHours()
    minutes = if new_date.getMinutes() < 10 then "0" + new_date.getMinutes() else new_date.getMinutes()
    seconds = if new_date.getSeconds() < 10 then "0" + new_date.getSeconds() else new_date.getSeconds()

    new_date_text = new_date.getFullYear() + "-" + month + "-" + day + ", " + hours + ":" + minutes + ":" + seconds
    return new_date_text

  user_time_offset_in_hours = new Date().getTimezoneOffset() * (-1) / 60;
  created_date_object = $ ".created-timestamp > .date"
  updated_date_object = $ ".updated-timestamp > .date"
  created_date_object.text calculate_local_time(created_date_object, user_time_offset_in_hours)
  updated_date_object.text calculate_local_time(updated_date_object, user_time_offset_in_hours)
