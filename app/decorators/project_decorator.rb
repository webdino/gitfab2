module ProjectDecorator
  def first_figure
    @first_figure ||= figures.first
  end

  def ogp_title
    "#{title} by #{owner.name}" if title
  end

  def ogp_description
    description
  end

  def ogp_image(base_url)
    first_figure&.content&.yield_self{ |content| URI.join(base_url, content.url).to_s }
  end

  def ogp_video
    first_figure&.link
  end
end
