$(function() {
  $(document).on("ajax:success", ".delete-comment", function() {
    const link = $(this);
    const li = link.closest("li");
    const comments = li.closest("ul");
    li.remove();
    changeCommentNumbers(comments);
    countDownComment(comments);
  });

  $(document).on("ajax:success", ".comment-form", function(event) {
    const form = $(this);
    const comments = form.siblings(".comments");
    comments.append(event.detail[0].html);
    form.find("#comment_body").val("");
    countUpComment(comments);
  });

  $(document).on("ajax:error", ".comment-form, .delete-comment", function(event) {
    const { message } = JSON.parse(event.detail[2].responseText);
    let msg = '';
    for (let key in message) {
      const value = message[key];
      msg = `${key} ${value}`;
    }
    alert(msg);
    event.preventDefault();
  });

  $(document).on("click", ".show-comments-btn", function() {
    const card_content = $(this).closest(".card-content");
    const comments = card_content.find(".comments-wrapper").first();
    if (comments.hasClass("is-closed")) {
      comments.removeClass("is-closed");
    } else {
      comments.addClass("is-closed");
    }
  });

  return $(document).on("click", ".close-comments-btn", function() {
    const comments = $(this).closest(".comments-wrapper").first();
    comments.addClass("is-closed");
  });
});

const changeCommentNumbers = function(comment_list) {
  const comments = comment_list.find(".comment");
  comments.each(function(index, comment) {
    const number = $(comment).find(".number").first();
    number.html(`No.${zeroFormat(index + 1, 3)}`);
  });
};

const zeroFormat = function(value, figures) {
  const value_length = String(value).length;
  if (figures > value_length) {
    return (new Array( (figures - value_length) + 1).join(0) ) + value;
  } else {
    return value;
  }
};

const countUpComment = function(comment_list) {
  const card_content = comment_list.closest(".card-content");
  const count = card_content.find(".show-comments-btn .count");
  const current_value = count.text();
  count.text((current_value - 0) + 1);
};

const countDownComment = function(comment_list) {
  const card_content = comment_list.closest(".card-content");
  const count = card_content.find(".show-comments-btn .count");
  const current_value = count.text();
  count.text(current_value - 0 - 1);
};
