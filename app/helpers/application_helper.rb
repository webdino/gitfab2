module ApplicationHelper
  def toggle_star_link_for likable
    return "" unless user_signed_in?
    if current_user.liked?(likable)
      link_to raw("&#9733; #{likable.likes.count}"),
        like_path(likable.likes.find_by(voter: current_user), like: {likable_id: likable.id, likable_type: likable.class.name}),
        remote: true, method: :delete, class: "toggle-star-btn",
        "data-label-on-click" => "&#9734; #{likable.likes.count + 1}"
    else
      link_to raw("&#9734; #{likable.likes.count}"),
        likes_path(like: {likable_id: likable.id, likable_type: likable.class.name}),
        remote: true, method: :post, class: "toggle-star-btn",
        "data-label-on-click" => "&#9733; #{likable.likes.count - 1}"
    end
  end
end
