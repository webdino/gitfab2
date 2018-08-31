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

class Figure < ApplicationRecord
  mount_uploader :content, FigureUploader
  belongs_to :figurable, polymorphic: true

  before_save :format_youtube_link

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

  private

    # YouTubeのURLを埋め込み可能な形式に置き換える
    def format_youtube_link
      return if link.nil? || !link.include?("youtube.com")
      query = URI(link).query
      return unless query
      youtube_id = CGI::parse(query)["v"][0]
      return unless youtube_id
      self.link = "https://www.youtube.com/embed/#{youtube_id}"
    end
end
