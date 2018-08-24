const path = require("path");
const CleanWebpackPlugin = require("clean-webpack-plugin");
const ManifestPlugin = require("webpack-manifest-plugin");

module.exports = {
  entry: {
    hello_world: "./app/frontend/hello_world.tsx",
  },

  output: {
    filename: "[name].[chunkhash].js",
    path: path.resolve(__dirname, "public/javascripts/dist"),
  },

  mode: "development",

  devtool: "inline-source-map",

  resolve: {
    extensions: [".ts", ".tsx", ".js", ".json"]
  },

  module: {
    rules: [
      { test: /\.tsx?$/, loader: "awesome-typescript-loader" },
      { enforce: "pre", test: /\.js$/, loader: "source-map-loader" }
    ]
  },

  plugins: [
    new CleanWebpackPlugin("public/javascripts/dist"),
    new ManifestPlugin({fileName: "webpack-manifest.json", publicPath: 'dist/'}),
  ],
};
