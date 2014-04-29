class Comment < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:title, :comment, :commentable_id, :commentable_type]

  include ActsAsCommentable::Comment

  acts_as_votable
  acts_as_paranoid

  belongs_to :commentable, polymorphic: true

  scope :created_at_desc, ->{order "created_at DESC"}

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user
end
