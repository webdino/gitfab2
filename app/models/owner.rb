class Owner
  def self.find(slug)
    find_by(slug) || raise(ActiveRecord::RecordNotFound.new(
                       "Couldn't find Owner with 'slug'=#{slug}",
                       "Owner", "slug", slug
                     ))
  end

  def self.find_by(slug)
    User.active.find_by(slug: slug) || Group.active.find_by(slug: slug)
  end
end
