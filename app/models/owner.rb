class Owner
  def self.find(slug)
    find_by(slug) || raise(ActiveRecord::RecordNotFound.new(
                       "Couldn't find Owner with 'slug'=#{slug}",
                       "Owner", "slug", slug
                     ))
  end

  def self.find_by(slug)
    User.find_by(slug: slug) || Group.find_by(slug: slug)
  end
end
