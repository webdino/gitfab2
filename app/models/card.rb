# == Schema Information
#
# Table name: cards
#
#  id             :integer          not null, primary key
#  comments_count :integer          default(0), not null
#  description    :text(4294967295)
#  position       :integer          default(0), not null
#  title          :string(255)
#  type           :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  project_id     :integer
#  state_id       :integer
#
# Indexes
#
#  index_cards_on_state_id  (state_id)
#  index_cards_project_id   (project_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#

class Card < ApplicationRecord
  include Figurable

  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments
  has_many :comments, class_name: "CardComment", dependent: :destroy
  has_many :contributions, dependent: :destroy
  has_many :contributors, through: :contributions, class_name: "User"

  validates :type, presence: true
  validate do
    if title.blank? && description.blank?
      errors.add(:base, "cannot make empty card.")
    end
  end

  def dup_document
    dup.tap do |card|
      card.figures = figures.map(&:dup_document)
      card.attachments = attachments.map(&:dup_document)
      card.comments_count = 0
      card.comments = []
    end
  end

  def htmlclass
    type.split(/::/).last.underscore
  end

  class << self
    def updatable_columns
      [:id, :title, :description, :type,
       figures_attributes: Figure.updatable_columns,
       attachments_attributes: Attachment.updatable_columns
      ]
    end

    def use_relative_model_naming?
      true
    end
  end


  # Override ActiveRecord::Inheritance::ClassMethods#find_sti_class
  #
  # バグ対策のオーバーライド。
  # 原因が突き止められなかったので、場当たり策ではあるが、Railsのメソッドをオーバーライドする。
  # 原因を突き止めて直すか、もしくは、もっと根本的なところでCardのSTIをやめたい。
  #
  # 問題が発生するようになった原因コミットはこれ。
  # https://github.com/rails/rails/commit/7c0f8c64fa1e8e055e2077255843f149e600024b
  # ただ、このコミット自体は間違っていなくて、元からあった問題がこのコミットで顕在化したと思われる。
  #
  # Card::State.createなどSTIの子クラスを作る際、create後にbelongs_to先であるProjectがCardを取得し直すらしく（この認識が正しいかは怪しい）、
  # その取得し直しはSTIを考慮していないみたいで他のSTIなクラスも一緒に取得して最終的にこの`find_sti_class`に関係のないtype_nameを渡し、
  # その結果、"Card::Usage is not a subclass of Card::State"のエラーが発生する。
  # そのため、そのパターンのエラーのみ無視するようにしている。
  def self.find_sti_class(type_name)
    super
  rescue ActiveRecord::SubclassNotFound => e
    if e.message.include?("Invalid single-table inheritance type")
      if store_full_sti_class
        ActiveSupport::Dependencies.constantize(type_name)
      else
        compute_type(type_name)
      end
    else
      raise e
    end
  end
end
