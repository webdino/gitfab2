Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_APP_ID'], ENV['GITHUB_APP_SECRET'], {
    scope: "read:user,user:email",
    callback_path: "/users/auth/github/callback"
  }
end
