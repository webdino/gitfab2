module GroupDecorator
  def ogp_title
    "#{name} on Fabble" if name
  end

  def ogp_description
  end

  def ogp_image(base_url)
    URI.join(base_url, avatar.url).to_s if avatar.present?
  end

  def ogp_video
  end
end
