# frozen_string_literal: true

module ProjectDecorator
  LICENSE_NAMES = {
    "by" => "Creative Commons - Attribution",
    "by-sa" => "Creative Commons - Attribution-ShareAlike",
    "by-nc" => "Creative Commons - Attribution-NonCommercial",
    "by-nc-sa" => "Creative Commons - Attribution-NonCommercial-ShareAlike"
  }

  def title_with_owner_name
    "#{owner.name}/#{title}"
  end

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

  def parent_license_index
    original ? Project.licenses[original.license] : 0
  end

  def license_url
    "https://creativecommons.org/licenses/#{license}/4.0"
  end

  def license_message
    project_link = link_to(title, project_path(owner, self))
    member_links = collaborators.unshift(owner).map{ |member| link_to(member.name, owner_path(member)) }.join(", ")
    license_link = link_to(LICENSE_NAMES[license], license_url, target: "_blank")
    "#{project_link} by #{member_links} is licensed under the #{license_link} license."
  end

  def thumbnail
    figure = figures.first
    return thumbnail_fallback_path unless figure

    if figure.link.present?
      "https://img.youtube.com/vi/#{figure.link.split('/').last}/mqdefault.jpg"
    elsif figure.content.present?
      figure.content.small.url
    else
      thumbnail_fallback_path
    end
  end

  def thumbnail_fallback_path
    "/images/fallback/blank.png"
  end
end
