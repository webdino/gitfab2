class CardCommentsController < ApplicationController
  def create
    card = Card.find(params[:card_id])
    comment = current_user.card_comments.build(card: card, body: params[:body])

    if comment.save
      notify_users(card)
      render :create, locals: { comment: comment, card_order: card.comments_count - 1 }
    else
      message = comment.errors.messages.presence || { "Error:": "Something's wrong" }
      render json: { success: false, message: message }, status: 400
    end
  end

  def destroy
    comment = CardComment.find_by(id: params[:id])
    if comment && can?(:destroy, comment) && comment.destroy
      render json: { success: true }
    else
      render json: { success: false }, status: 400
    end
  end

  private

    def notify_users(card)
      project = card.project
      users = project.notifiable_users(current_user)
      return if users.blank?

      if card.class.name == 'Card::NoteCard'
        url = project_note_card_path(project.owner, project, card)
        body = "#{current_user.name} commented on your memo of #{project.title}."
      else
        url = project_path(project.owner, project)
        body = "#{current_user.name} commented on your recipe of #{project.title}."
      end
      project.notify(users, current_user, url, body)
    end
end
