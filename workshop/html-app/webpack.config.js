'use strict';

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  // BrightSign's JavaScript runtime is Node-compatible, not a browser.
  // Target 'node' gives access to Node APIs (fs, net, etc.) without polyfills.
  target: 'node',

  entry: './src/index.js',

  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
  },

  // @brightsign/* packages are provided by the player's runtime — do not bundle them.
  externals: {
    '@brightsign/deviceinfo': 'commonjs @brightsign/deviceinfo',
    '@brightsign/registry':   'commonjs @brightsign/registry',
    '@brightsign/videooutput': 'commonjs @brightsign/videooutput',
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              ['@babel/preset-env', { targets: { node: '14' } }]
            ],
          },
        },
      },
    ],
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
      inject: false,
    }),
  ],

  devtool: 'eval-source-map',
};
