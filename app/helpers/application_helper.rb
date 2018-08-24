module ApplicationHelper
  def javascript_webpack_tag(filename)
    javascript_include_tag(webpack_manifest["#{filename}.js"], skip_pipeline: true, defer: true)
  end

  private

    def webpack_manifest
      JSON.load(Rails.root.join("public", "javascripts", "dist", "webpack-manifest.json"))
    end
end
