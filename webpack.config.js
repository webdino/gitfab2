const path = require("path");
const CleanWebpackPlugin = require("clean-webpack-plugin");
const ManifestPlugin = require("webpack-manifest-plugin");

module.exports = (_, argv) => {
  const isProduction = argv.mode === "production";
  const dist = path.resolve(__dirname, "public/javascripts/dist");

  return {
    entry: {
      like: "./app/frontend/like.ts"
    },

    output: {
      filename: "[name].[chunkhash].js",
      path: dist
    },

    mode: isProduction ? "production" : "development",

    devtool: isProduction ? "source-map" : "inline-source-map",

    resolve: {
      extensions: [".ts", ".tsx", ".js"]
    },

    module: {
      rules: [{ test: /\.tsx?$/, loader: "ts-loader" }]
    },

    plugins: [
      new CleanWebpackPlugin(dist),
      new ManifestPlugin({
        fileName: "webpack-manifest.json",
        publicPath: "dist/"
      })
    ]
  };
};
