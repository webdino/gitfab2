module Gitfab::HasVideoOrPhoto
  extend ActiveSupport::Concern
  YOUTUBE_EMBED_URL_BASE = "http://www.youtube.com/embed/"
  included do
    before_save :clear_video_id_or_photo_if_needed

    def youtube_embed_url
      "#{YOUTUBE_EMBED_URL_BASE}#{self.video_id}"
    end

    private
    def clear_video_id_or_photo_if_needed
      if photo_should_be_removed?
        self.remove_photo!
      elsif video_id_should_be_removed?
        self.video_id = nil
      end
    end

    def photo_should_be_removed?
      video_id.present? && video_id_changed? && photo.present?
    end

    def video_id_should_be_removed?
      photo.present? && photo_changed? && video_id.present?
    end
  end
end
