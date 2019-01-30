# Be sure to restart your server when you modify this file.

Rails.application.config.assets.precompile += %w(
    application.js
    groups.js    groups.css
    dashboard.js dashboard.css
    admin.js admin.css
    project.css  project.js
    user.js      user.css
    masonry.pkgd.min.js
    static_pages.js
    static_pages.css
    slideshow.css slideshow.js
  )

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
