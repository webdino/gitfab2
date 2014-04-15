module ApplicationHelper
  def toggle_star_link_for votable
    if user_signed_in? && current_user.liked?(votable)
      link_to raw("&#9733;"), like_path(votable.likes.find_by voter: current_user), remote: true, method: :delete, class: "toggle-star-btn"
    else
      link_to raw("&#9734;"), likes_path(like: {votable_id: votable.id, votable_type: votable.class.name}), remote: true, method: :post, class: "toggle-star-btn"
    end
  end
end
