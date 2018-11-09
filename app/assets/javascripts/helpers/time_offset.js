$(function() {
  const calculate_local_time = function(date_object, time_offset_in_hours) {
    const date_text = date_object.text().split(", ");
    if (date_text[1] === undefined) {
      return;
    }
    const date = date_text[0].split("-");
    const time = date_text[1].split(":");
    const new_date = new Date(date[0] - 0, date[1] - 0, date[2] - 0, time[0] - 0, time[1] - 0, time[2] - 0);
    new_date.setHours((time[0] - 0) + time_offset_in_hours);

    const month = new_date.getMonth() < 10 ? `0${new_date.getMonth()}` : new_date.getMonth();
    const day = new_date.getDate() < 10 ? `0${new_date.getDate()}` : new_date.getDate();
    const hours = new_date.getHours() < 10 ? `0${new_date.getHours()}` : new_date.getHours();
    const minutes = new_date.getMinutes() < 10 ? `0${new_date.getMinutes()}` : new_date.getMinutes();
    const seconds = new_date.getSeconds() < 10 ? `0${new_date.getSeconds()}` : new_date.getSeconds();

    const new_date_text = new_date.getFullYear() + "-" + month + "-" + day + ", " + hours + ":" + minutes + ":" + seconds;
    return new_date_text;
  };

  const user_time_offset_in_hours = (new Date().getTimezoneOffset() * (-1)) / 60;
  const created_date_object = $(".created-timestamp > .date");
  const updated_date_object = $(".updated-timestamp > .date");
  created_date_object.text(calculate_local_time(created_date_object, user_time_offset_in_hours));
  updated_date_object.text(calculate_local_time(updated_date_object, user_time_offset_in_hours));
});
