FriendlyId.defaults do |config|
  config.use Module.new {
    def normalize_friendly_id(text)
      text.to_url
    end
  }
end
