Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_APP_ID"], ENV["GITHUB_APP_SECRET"], {
    scope: "read:user,user:email",
    callback_path: "/users/auth/github/callback"
  }
  provider :google_oauth2, ENV["GOOGLE_APP_ID"], ENV["GOOGLE_APP_SECRET"], {
    callback_path: "/users/auth/google_oauth2/callback"
  }
  provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], {
    callback_path: "/users/auth/facebook/callback"
  }
end
