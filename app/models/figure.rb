# == Schema Information
#
# Table name: figures
#
#  id             :integer          not null, primary key
#  content        :string(255)
#  figurable_type :string(255)
#  link           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  figurable_id   :integer
#
# Indexes
#
#  index_figures_figurable  (figurable_type,figurable_id)
#

class Figure < ActiveRecord::Base

  mount_uploader :content, FigureUploader
  # TODO: required: true を付けられるかどうか要検討
  belongs_to :figurable, polymorphic: true

  def dup_document
    dup.tap do |doc|
      doc.content = content&.file
    end
  end

  class << self
    def updatable_columns
      [:id, :link, :content, :_destroy]
    end
  end
end
