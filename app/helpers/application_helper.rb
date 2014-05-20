module ApplicationHelper
  def toggle_star_link_for votable
    return "" unless user_signed_in?
    if current_user.liked?(votable)
      link_to raw("&#9733; #{votable.count_label}"),
        like_path(votable.likes.find_by(voter: current_user), like: {votable_id: votable.id, votable_type: votable.class.name}),
        remote: true, method: :delete, class: "toggle-star-btn",
        "data-label-on-click" => "&#9734; #{votable.decreased_count_label}"
    else
      link_to raw("&#9734; #{votable.count_label}"),
        likes_path(like: {votable_id: votable.id, votable_type: votable.class.name}),
        remote: true, method: :post, class: "toggle-star-btn",
        "data-label-on-click" => "&#9733; #{votable.increased_count_label}"
    end
  end
end
