Rails.application.config.assets.paths += %w("/vendor/assets/javascripts")
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
