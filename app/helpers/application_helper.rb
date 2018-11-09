module ApplicationHelper
  def javascript_webpack_tag(filename)
    javascript_include_tag(webpack_manifest["#{filename}.js"], skip_pipeline: true, defer: true)
  end

  def link_to_github_sign_in
    link_to "Sign in with GitHub", "/auth/github", class: "btn"
  end

  def link_to_google_sign_in
    link_to "Sign in with Google", "/auth/google_oauth2", class: "btn"
  end

  def link_to_facebook_sign_in
    link_to "Sign in with Facebook", "/auth/facebook", class: "btn"
  end

  private

    def webpack_manifest
      JSON.load(Rails.root.join("public", "javascripts", "dist", "webpack-manifest.json"))
    end
end
