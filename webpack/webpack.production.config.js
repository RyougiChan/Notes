const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CleanWebpackPlugin = require('clean-webpack-plugin');

module.exports = {
    devtool: 'null',
    entry: {
        main: __dirname + "/app/main.js",//已多次提及的唯一入口文件
    },
    output: {
        path: __dirname + "/build",//打包后的文件存放的地方
        filename: "bundle.[chunkhash].js"//打包后输出文件的文件名
    },
    devServer: {
      contentBase: "./public", //本地服务器所加载的页面所在的目录
      // hot: true, // 热更新
      historyApiFallback: true, //不跳转
      inline: true //实时刷新
      // 其他参数 https://webpack.js.org/configuration/dev-server/
    },
    module: {
        rules: [
            {
                test: /(\.jsx|\.js)$/,
                use: {
                    loader: "babel-loader"
                },
                exclude: /node_modules/
            },
            {
                test: /(\.css$)/,
                use: [
                    {
                        loader: MiniCssExtractPlugin.loader
                    },
                    {
                        loader: "css-loader",
                        options: {
                            modules: true,
                            localIdentName: '[name]__[local]--[hash:base64:5]'
                        }
                    },
                    {
                        loader: "postcss-loader"
                    },
                ]
            }
        ]
    },
    plugins: [
        new webpack.BannerPlugin('Copyright © RyougiChan'),
        new HtmlWebpackPlugin({
            template: __dirname + "/app/index.tmpl.html"
        }),
        // new webpack.HotModuleReplacementPlugin(),
        new webpack.optimize.OccurrenceOrderPlugin(),
        new MiniCssExtractPlugin({
            // Options similar to the same options in webpackOptions.output
            // both options are optional
            filename: "[name].css",
            chunkFilename: "[id].css"
          }),
        new CleanWebpackPlugin(
            'build/*.*', 
            {
                root: __dirname,
                verbose: true,
                dry: false
            }
        )
    ],
};