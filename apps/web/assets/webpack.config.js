const ExtractTextPlugin = require('extract-text-webpack-plugin');
const path = require('path');

module.exports = {

  entry: './js/app',
  output: {
    path: path.resolve(__dirname, '../priv/static'),
    filename: 'js/app.js'
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: [/node_modules/, /priv\/static/],
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env']
          }
        }
      },
      {
        test: /\.(sass|scss)$/,
        use: [{
            loader: "style-loader"
        }, {
            loader: "css-loader"
        }, {
            loader: "sass-loader"
        }]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/, /tests/],
        use: {
          loader: 'elm-webpack-loader',
          options: { debug: true }
        }
      }
    ],
    noParse: [/\.elm$/]
  },

  plugins: [ new ExtractTextPlugin("css/app.sass") ]

};
