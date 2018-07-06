Rails.application.config.assets.precompile += %w(
    application.js
    groups.js    groups.css
    dashboard.js dashboard.css
    posts.js     posts.css
    project.css  project.js
    user.js      user.css
    global_projects.js
    global_projects.css
    masonry.pkgd.min.js
    static_pages.js
    static_pages.css
  )

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
