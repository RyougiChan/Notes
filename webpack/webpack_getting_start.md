# webpack 入门

[toc]

**参考资料基于 `webpack 3.5.3`， 实际使用 webpack 版本为 `4.29.5`**

## 起步

### 安装

```powershell
# global
npm install -g webpack
# dev
npm install --save-dev webpack
```

### 使用准备

#### 创建标准的 npm 说明文件 `package.json`

```powershell
npm init
```

####  安装 webpack

```powershell
npm install --save-dev webpack
```

---

**ERR 记录**

```powershell
npm ERR! code Z_BUF_ERROR
npm ERR! errno -5
npm ERR! zlib: unexpected end of file
```

> 网络问题引起，解决方法：更换 npm 镜像源

```powershell
npm config set registry https://registry.npm.taobao.org
```

---

#### 初始化目录和文件结构

```powershell
│  package-lock.json
│  package.json
├─app
│       Greeter.js
│       main.js
├─node_modules
└─public
        index.html
```

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Webpack Sample Project</title>
  </head>
  <body>
    <div id='root'>
    </div>
    <script src="bundle.js"></script>
  </body>
</html>
```

```js
// Greeter.js
module.exports = function() {
  var greet = document.createElement('div');
  greet.textContent = "Hi there and greetings!";
  return greet;
};
```

```js
//main.js 
const greeter = require('./Greeter.js');
document.querySelector("#root").appendChild(greeter());
```

### 使用 webpack

#### 在 shell 中使用 webpack

```powershell
# webpack 全局安装
webpack app/main.js public/bundle.js

# webpack 非全局安装
node_modules/.bin/webpack app/main.js public/bundle.js
```

---

**ERR 记录**

```powershell
One CLI for webpack must be installed. These are recommended choices, delivered as separate packages:
 - webpack-cli (https://github.com/webpack/webpack-cli)
   The original webpack full-featured CLI.
We will use "npm" to install the CLI via "npm install -D".
Do you want to install 'webpack-cli' (yes/no):
You need to install 'webpack-cli' to use webpack via CLI.
You can also install the CLI manually.
```

> 在 webpack 3 中，webpack 本身和它的 CLI 位于同一个包中，但在版本4中，他们将两者分开来更好地管理它们。解决方法：全局安装 webpack-cli(如果在全局使用)。

```powershell
npm install webpack-cli -g
```

**ERR 记录**

```powershell
node_modules/.bin/webpack app/main.js public/bundle.js

#...
ERROR in multi ./app/main.js public/bundle.js
Module not found: Error: Can't resolve 'public/bundle.js' in 'D:\Documents and Settings\Desktop\VueStarter'
 @ multi ./app/main.js public/bundle.js main[1]
```

> webpack 版本过高引起，使用 webpack 4 时命令如下

```powershell
node_modules/.bin/webpack app/main.js -o public/bundle.js
```

---

#### 通过配置文件来使用 webpack 1

##### 新建 `webpack.config.js` 文件

```powershell
│  package-lock.json
│  package.json
│  webpack.config.js
│
├─app
│      Greeter.js
│      main.js
│
├─node_modules
│
└─public
        bundle.js
        index.html
```

> 注：`__dirname` 是 node.js 中的一个全局变量，它指向当前执行脚本所在的目录。

##### 写入配置

```js
module.exports = {
  entry:  __dirname + "/app/main.js",//唯一入口文件
  output: {
    path: __dirname + "/public",//打包后的文件存放的地方
    filename: "bundle.js"//打包后输出文件的文件名
  }
}
```

##### 执行 shell 命令

```powershell
# global
webpack

# dev
node_modules/.bin/webpack
```

#### 通过配置文件来使用 webpack 2

##### 配置 `package.json` 文件中的命令

```json
{
  "name": "vuestarter",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "webpack", // + 1
    "build": "webpack"  // + 2
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "webpack": "^4.29.5",
    "webpack-cli": "^3.2.3"
  }
}

```

##### shell 执行命令

```powershell
# 1 脚本名称是 start
npm start

# 2 脚本名称不是 start。使用 npm run {script name}
npm run build
```

## Webpack 的功能

### Source Maps

**！最好仅在开发阶段使用**

> 提供了一种对应编译文件和源文件的方法，使得编译后的代码**可读性更高**，也更容易**调试**。

在 webpack 的配置文件中配置 source maps，需要配置 `devtool`，它有以下几种不同的配置选项等（还有其他组合方式），各具优缺点，描述如下：

| devtool         | description      |
|-----------------|------------------|
| `eval`          | 每个 module 会封装到 `eval` 里包裹起来执行，并且会在末尾追加注释 `//@ sourceURL` |
| `source-map`     | 在一个**单独**的文件中产生一个**完整且功能完全**的文件。这个文件具有最好的 source map，但是它会减慢打包速度； |
| `hidden-source-map` | 和 source-map 一样，但不会在 bundle 末尾追加注释 |
| `inline-source-map` | 生成一个 DataUrl 形式的 SourceMap 文件 |
| `eval-source-map` | 使用 `eval` 打包源文件模块，在**同一个**文件中生成**干净完整**的 source map。这个选项可以在不影响构建速度的前提下生成完整的 sourcemap，但是对打包后输出的 JS 文件的执行具有性能和安全的隐患。在开发阶段这是一个非常好的选项，在生产阶段则一定不要启用这个选项； |
| `cheap-source-map` | 生成一个**没有列信息**（column-mappings）的 SourceMaps 文件，**不包含 loader** 的 sourcemap |
| `cheap-module-source-map` | 在一个单独的文件中生成一个**不带列映射**的 map，**不带列映射**提高了打包速度，但是也使得浏览器开发者工具只能对应到具体的行，不能对应到具体的列（符号），会对调试造成不便；|
| `cheap-module-eval-source-map` | 这是在打包文件时**最快**的生成 source map 的方法，生成的 Source Map  会和打包后的 JavaScript 文件同行显示，没有列映射，和 `eval-source-map` 选项具有相似的缺点；|

> `cheap-module-eval-source-map` 方法构建速度更快，但是不利于调试，推荐在大型项目考虑时间成本时使用。生产环境推荐：`cheap-module-source-map`

配置 webpack.config.js

```js
// webpack.config.js
module.exports = {
  devtool: 'eval-source-map',
  entry:  __dirname + "/app/main.js",
  output: {
    path: __dirname + "/public",
    filename: "bundle.js"
  }
}
```

### [DevServer](https://webpack.js.org/configuration/dev-server/) 构建本地服务器

- 安装独立的依赖项

```powershell
npm install --save-dev webpack-dev-server
```

- 配置 `webpack.config.js` 文件

```js
// webpack.config.js
module.exports = {
  devtool: 'eval-source-map',

  entry:  __dirname + "/app/main.js",
  output: {
    path: __dirname + "/public",
    filename: "bundle.js"
  },

  devServer: {
    contentBase: "./public", //本地服务器所加载的页面所在的目录
    historyApiFallback: true, //不跳转
    inline: true //实时刷新
    // 其他参数 https://webpack.js.org/configuration/dev-server/
  } 
}
```

- 配置 `package.json` 添加 `scripts` 命令

```json
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "webpack",
    "server": "webpack-dev-server --open"
  },
```

- 在 shell 中执行命令 `npm run server`

### Loaders

> webpack loaders 在 webpack.config.js 中的 `modules` 关键字下进行配置，相关属性：

| name    | reqiored | description        |
|---------|----------|--------------------|
| `test`  | true     | 用于匹配 loaders 所处理文件的拓展名的正则表达式|
| `loader`| true     | loader 的名称 |
| `include`| false   | 指定必须处理的文件/文件夹 |
| `exclude`| false   | 屏蔽不需处理的文件/文件夹 |
| `query` | false    | 为 loader 提供额外的设置选项

#### Babel 编译 JavaScript 的平台

> 1. 让你能使用最新的 JavaScript 代码（ES6，ES7...），而不用管新标准是否被当前使用的浏览器完全支持；
2. 让你能使用基于 JavaScript 进行了拓展的语言，比如 React 的 JSX；

- 安装依赖

```powershell
npm install --save-dev babel-core babel-loader babel-preset-env babel-preset-react
```

`babel-preset-env`: 解析 ES6
`babel-preset-react`: 解析 JSX

- 配置 webpack.config.js

```js
    ...
    module: {
        rules: [
            {
                test: /(\.jsx|\.js)$/,
                use: {
                    loader: "babel-loader",
                    options: {
                        presets: [
                            "env", "react"
                        ]
                    }
                },
                exclude: /node_modules/
            }
        ]
    }
```

- 测试
  - 将 greetingText 写入 json 文件，放在 app 目录下
  
  ```json
  {
       "greetText": "Hi there and greet from JSON!"
  }
  ```
  
  - 使用 React 和 ES6 语法

  ```powershell
  // 安装 React 依赖
  npm install --save react react-dom
  ```
    
  ```js
  //Greeter.js
    import React, {Component} from 'react'
    import config from './config.json';
    
    class Greeter extends Component{
      render() {
        return (
          <div>
            {config.greetText}
          </div>
        );
      }
    }
    
    export default Greeter
  ```
  
  ```js
  // main.js
  import React from 'react';
  import {render} from 'react-dom';
  import Greeter from './Greeter';

  render(<Greeter />, document.getElementById('root'));
  ```
  
  - 运行 npm start
  
---

**ERR 记录**

```powershell
ERROR in ./app/main.js
Module build failed (from ./node_modules/babel-loader/lib/index.js):
Error: Cannot find module '@babel/core'
 babel-loader@8 requires Babel 7.x (the package '@babel/core'). If you'd like to use Babel 6.x ('babel-core'), you should install 'babel-loader@7'.
```

> babel-loader 要求的 babel-core 版本太低引起。

```json
// package.json
...
    "babel-core": "^6.26.3",    // too low
    "babel-loader": "^8.0.5",   // too high
```

> 解决方案：提高 babel-core 版本或降低 babel-loader 版本

```powershell
npm install --save-dev babel-loader@7
# or
npm install --save-dev @babel/core
```

```json
// package.json
...
    "babel-core": "^6.26.3",
    "babel-loader": "^7.1.5",
```

---

- Babel 配置的问题

Babel 可以完全在 `webpack.config.js` 中进行配置，但是考虑到 babel 具有非常多的配置选项，在单一的 `webpack.config.js` 文件中进行配置往往使得这个文件显得太复杂，因此一些开发者支持把 babel 的配置选项放在一个单独的名为 `.babelrc` 的配置文件中。

#### 模块

> Webpack 把所有的文件都都当做模块处理，JavaScript 代码，CSS 和 fonts 以及图片等等通过合适的 loader 都可以被处理。

---

##### CSS: `css-loader` 和 `style-loader`
  - `css-loader` 使你能够使用类似 `@import` 和 `url(...)` 的方法实现 `require()` 的功能
  - `style-loader` 将所有的计算后的样式加入页面中。二者组合在一起使你能够把样式表嵌入 webpack 打包后的 JS 文件中。

```powershell
// 安装
npm install --save-dev style-loader css-loader
```

```js
//使用
module.exports = {

   ...
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
                test: /\.css$/,
                use: [
                    {
                        loader: "style-loader"
                    }, {
                        loader: "css-loader"
                    }
                ]
            }
        ]
    }
};
```

app 目录下新建 main.css

```css
html {
    box-sizing: border-box;
    -ms-text-size-adjust: 100%;
    -webkit-text-size-adjust: 100%;
}

*, *:before, *:after {
    box-sizing: inherit;
}

body {
    margin: 0;
    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
}

h1, h2, h3, h4, h5, h6, p, ul {
    margin: 0;
    padding: 0;
}
```

main.js 中添加 `import`

```js
//main.js
import React from 'react';
import {render} from 'react-dom';
import Greeter from './Greeter';

import './main.css';//使用require导入css文件

render(<Greeter />, document.getElementById('root'));
```

---

##### CSS module

> 把 JS 的模块化思想带入 CSS 中，通过 CSS 模块，所有的类名，动画名默认都只作用于当前模块，有效避免全局污染。

在 webpack 中配置启用

```json
// webpack.config.json
...
                use: [
                    {
                        loader: "style-loader"
                    }, {
                        loader: "css-loader",
                        options: {
                            modules: true, // 指定启用css modules
                            localIdentName: '[name]__[local]--[hash:base64:5]' // 指定css的类名格式
                        }
                    }
                ]

```

app 目录下新建 Greeter.css，并导入到 Greeter.js

```css
/* Greeter.css */
.root {
  background-color: #eee;
  padding: 10px;
  border: 3px solid #ccc;
}
```

```js
import React, {Component} from 'react';
import config from './config.json';
import styles from './Greeter.css';//导入

class Greeter extends Component{
  render() {
    return (
      <div className={styles.root}> //使用cssModule添加类名的方法
        {config.greetText}
      </div>
    );
  }
}

export default Greeter
```

编译 `npm start`

---

##### CSS预处理器

> Sass 和 Less 之类的预处理器是对原生 CSS 的拓展，它们允许你使用类似于 `variables`, `nesting`, `mixins`, `inheritance` 等不存在于 CSS 中的特性来写 CSS，CSS 预处理器可以这些特殊类型的语句转化为浏览器可识别的 CSS 语句，

- Less Loader 处理 `.less` 文件

```powershell
npm install --save-dev less less-loader
```
- Sass Loader 处理 `.scss` 文件

```powershell
npm install --save-dev node-sass sass-loader
```
- Stylus Loader 处理 `.styl` 文件

```powershell
npm install --save-dev stylus stylus-loader
```

- PostCSS + autoprefixer(自动添加前缀的插件)

```powershell
npm install --save-dev postcss-loader autoprefixer
```

webpack.config.js 添加 postcss-loader

```js
//webpack.config.js
module.exports = {
    ...
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
                test: /\.css$/,
                use: [
                    {
                        loader: "style-loader"
                    }, {
                        loader: "css-loader",
                        options: {
                            modules: true
                        }
                    }, {
                        loader: "postcss-loader"
                    }
                ]
            }
        ]
    }
}
```

根目录新建 `postcss.config.js`，必须设置支持的浏览器才会自动添加添加浏览器兼容

```js
//postcss.config.js
module.exports = {
    plugins: [
        require('autoprefixer')({
            "browsers": [
                "defaults",
                "not ie < 11",
                "last 2 versions",
                "> 1%",
                "iOS 7",
                "last 3 iOS versions"
            ]
        })
    ]
}
```

---

### 插件(Plugins)

插件（Plugins）用来拓展 Webpack 功能，它们会在整个构建过程中生效，执行相关的任务。而 Loaders 是在打包构建过程中用来处理源文件的（JSX, Scss, Less），一次处理一个，插件并不直接操作单个文件，它直接对整个构建过程其作用。

> 使用方法(以 [`banner-plugin`](https://webpack.js.org/plugins/banner-plugin/) 内置插件使用示例)

```js
// webpack.config.js
const webpack = require('webpack');

...
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
                        loader: "style-loader"
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
                    }
                ]
            }
        ]
    },
    plugins: [
        new webpack.BannerPlugin('Copyright © RyougiChan')
    ]

```

#### HtmlWebpackPlugin

> 依据一个简单的 `index.html` 模板，生成一个自动引用你打包后的 JS 文件的新 `index.html`。这在每次生成的 js 文件名称不同时非常有用（比如添加了 `hash` 值）。

- 安装

```powershell
npm install --save-dev html-webpack-plugin
```

- 项目结构

删除 public 文件夹，在 app 目录添加 `index.tmpl.html` 文件模板

```powershell
│  .babelrc
│  package-lock.json
│  package.json
│  postcss.config.js
│  webpack.config.js
│
└─app
        config.json
        Greeter.css
        Greeter.js
        index.tmpl.html
        main.css
        main.js
```

- webpack 配置

```js
// webpack.config.js
const HtmlWebpackPlugin = require('html-webpack-plugin');
...
output: {
        path: __dirname + "/build",//打包后的文件存放的地方
        filename: "bundle.js"//打包后输出文件的文件名
    },
...
,
    plugins: [
        new webpack.BannerPlugin('Copyright © RyougiChan'),
        new HtmlWebpackPlugin({
            template: __dirname + "/app/index.tmpl.html"
        })
    ],
```

- 编译 `npm start`

```powershell
│  .babelrc
│  package-lock.json
│  package.json
│  postcss.config.js
│  webpack.config.js
│
├─app
│      config.json
│      Greeter.css
│      Greeter.js
│      index.tmpl.html
│      main.css
│      main.js
│
└─build
        bundle.js
        index.html
```

---

**ERR 记录**

```powershell
Child html-webpack-plugin for "index.html":

    ERROR in Entry module not found: Error: Can't resolve 'D:\Documents and Settings\Desktop\VueStarter\app\index.tmpl.html' in 'D:\Documents and Settings\Desktop\VueStarter'
npm ERR! code ELIFECYCLE
npm ERR! errno 2
npm ERR! vuestarter@1.0.0 start: `webpack`
npm ERR! Exit status 2
npm ERR!
npm ERR! Failed at the vuestarter@1.0.0 start script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.
```

> 由模板不存在引起(示例中为 `/app/index.tmpl.html` 不存在)，直接修复文件即可

---

#### Hot Module Replacement(热替换)

`Hot Module Replacement(HMR)`允许你在修改组件代码后，自动刷新实时预览修改后的效果，即实时更新。

- 配置 webpack

```js
// webpack.config.js
...
devServer: {
      contentBase: "./public", //本地服务器所加载的页面所在的目录
      hot: true, // +热更新
      historyApiFallback: true, //不跳转
      inline: true //实时刷新
      // 其他参数 https://webpack.js.org/configuration/dev-server/
    },
    ...
    plugins: [
        new webpack.BannerPlugin('Copyright © RyougiChan'),
        new HtmlWebpackPlugin({
            template: __dirname + "/app/index.tmpl.html"
        }),
        new webpack.HotModuleReplacementPlugin() // +
    ],
```

- JS 模块中执行一个 Webpack 提供的 API

监听 `Greeter.js` 内部发生变更时可以告诉 webpack 接受更新的模块，同时刷新页面。

```js
// main.js
import React from 'react';
import {render} from 'react-dom';
import Greeter from './Greeter';

import './main.css';//使用require导入css文件

render(<Greeter />, document.getElementById('root'));

if(module.hot)
{
    module.hot.accept('./Greeter.js', () => {
        console.log('Accepting the updated Greeter');
        window.location.reload();
    });
}
```

### Production 阶段

#### `webpack.production.config.js` 配置文件

```js
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    devtool: 'null',
    entry: __dirname + "/app/main.js",//已多次提及的唯一入口文件
    output: {
        path: __dirname + "/build",//打包后的文件存放的地方
        filename: "bundle.js"//打包后输出文件的文件名
    },
    devServer: {
      contentBase: "./public", //本地服务器所加载的页面所在的目录
      hot: true, // 热更新
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
                        loader: "style-loader"
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
                    }
                ]
            }
        ]
    },
    plugins: [
        new webpack.BannerPlugin('Copyright © RyougiChan'),
        new HtmlWebpackPlugin({
            template: __dirname + "/app/index.tmpl.html"
        }),
        new webpack.HotModuleReplacementPlugin()
    ],
};
```

#### package.json 配置

windows 环境 `build` 需要配置为

```json
"build": "set NODE_ENV=production && webpack --config ./webpack.production.config.js --progress"
```

```js
//package.json
{
  "name": "test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "webpack",
    "server": "webpack-dev-server --open",
    "build": "NODE_ENV=production webpack --config ./webpack.production.config.js --progress"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
...
  },
  "dependencies": {
    "react": "^15.6.1",
    "react-dom": "^15.6.1"
  }
}
```

#### 三个优化插件

- `OccurenceOrderPlugin` 内置插件，为组件分配 ID，通过这个插件 webpack 可以分析和优先考虑使用最多的模块，并为它们分配最小的 ID
- `UglifyJsPlugin` 内置插件，压缩 JS 代码(Webpack 4 已弃用，参考 ERR 记录的描述)；
- `ExtractTextPlugin` 分离 CSS 和 JS 文件(Webpack 4 不支持，改用 [mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin)，参考 ERR 记录)

##### 添加 ExtractTextPlugin

```powershell
npm install --save-dev extract-text-webpack-plugin
```

##### 引用插件

```js
// webpack.production.config.js
const ExtractTextPlugin = require('extract-text-webpack-plugin');
...
    plugins: [
        new webpack.BannerPlugin('Copyright © RyougiChan'),
        new HtmlWebpackPlugin({
            template: __dirname + "/app/index.tmpl.html"
        }),
        new webpack.HotModuleReplacementPlugin(),
        new webpack.optimize.OccurrenceOrderPlugin(),
        new webpack.optimize.UglifyJsPlugin(),
        new ExtractTextPlugin("style.css")
    ],
```

---

**ERR 记录**

```powershell
Error: webpack.optimize.UglifyJsPlugin has been removed, please use config.optimization.minimize instead.
```

> 从 Webpack 4 开始，`webpack.optimize.UglifyJsPlugin` 已被弃用。如[手册](https://webpack.js.org/configuration/optimization/)所述，插件可以用 `minimize` 选项替换。可以通过指定 `UglifyJsPlugin` 实例为插件提供自定义配置。

```js
const webpack = require("webpack");
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  // ...
  optimization: {
    minimize: true,
    minimizer: [new UglifyJsPlugin({
        cache: true,
        parallel: true,
        uglifyOptions: {
          compress: false,
          ecma: 6,
          mangle: true
        },
        sourceMap: true
    })]
  }
};
```

```powershell
Error: Chunk.entrypoints: Use Chunks.groupsIterable and filter by instanceof Entrypoint instead
```

> [extract-text-webpack-plugin](https://github.com/webpack-contrib/extract-text-webpack-plugin#Usage): Since webpack v4 the extract-text-webpack-plugin should not be used for css. Use [mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin) instead. 

```powershell
npm install --save-dev mini-css-extract-plugin
```

```js
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
module.exports = {
  plugins: [
    new MiniCssExtractPlugin({
      // Options similar to the same options in webpackOptions.output
      // both options are optional
      filename: "[name].css",
      chunkFilename: "[id].css"
    })
  ],
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
            options: {
              // you can specify a publicPath here
              // by default it use publicPath in webpackOptions.output
              publicPath: '../'
            }
          },
          "css-loader"
        ]
      }
    ]
  }
}
```

```powershell
ERROR in ./app/Greeter.css (./node_modules/css-loader/dist/cjs.js??ref--5-1!./node_modules/postcss-loader/src!./node_modules/mini-css-extract-plugin/dist/loader.js!./app/Greeter.css)
Module build failed (from ./node_modules/mini-css-extract-plugin/dist/loader.js):
ModuleParseError: Module parse failed: Unexpected token (3:0)
You may need an appropriate loader to handle this file type.
| /* Greeter.css */
|
> .root {
|     display: flex;
|     background-color: #eee;
    at handleParseError (D:\Documents and Settings\Desktop\VueStarter\node_modules\webpack\lib\NormalModule.js:447:19)
    at doBuild.err (D:\Documents and Settings\Desktop\VueStarter\node_modules\webpack\lib\NormalModule.js:481:5)
    at runLoaders (D:\Documents and Settings\Desktop\VueStarter\node_modules\webpack\lib\NormalModule.js:342:12)
    at D:\Documents and Settings\Desktop\VueStarter\node_modules\loader-runner\lib\LoaderRunner.js:373:3
    at iterateNormalLoaders (D:\Documents and Settings\Desktop\VueStarter\node_modules\loader-runner\lib\LoaderRunner.js:214:10)
    at Array.<anonymous> (D:\Documents and Settings\Desktop\VueStarter\node_modules\loader-runner\lib\LoaderRunner.js:205:4)
    at Storage.finished (D:\Documents and Settings\Desktop\VueStarter\node_modules\enhanced-resolve\lib\CachedInputFileSystem.js:43:16)
    at provider (D:\Documents and Settings\Desktop\VueStarter\node_modules\enhanced-resolve\lib\CachedInputFileSystem.js:79:9)
    at D:\Documents and Settings\Desktop\VueStarter\node_modules\graceful-fs\graceful-fs.js:90:16
    at FSReqWrap.readFileAfterClose [as oncomplete] (internal/fs/read_file_context.js:53:3)
 @ ./app/Greeter.css 2:14-188 21:1-42:3 22:19-193
 @ ./app/Greeter.js
 @ ./app/main.js
```

> MiniCssExtractPlugin.loader 和 style-loader 互斥，仅使用其中一种。

```powershell
Cannot use [chunkhash] or [contenthash] for chunk in 'bundle-[chunkhash].js' (use [hash] instead)
```

> 热替换插件不能与 `contenthash`, `chunkhash` 一起使用，需要移除 `--hot` 参数和配置中的 `new webpack.HotModuleReplacementPlugin()` 语句

---

#### 缓存

webpack 通过添加特殊的字符串混合体([name], [id], [hash], [chunkhash], [contenthash])中的哈希值打包到文件名中

- `hash`: 工程级别的生成策略，每次修改任何一个文件，所有文件名的 `hash` 值都将改变。所以一旦修改了任何一个文件，整个项目的文件缓存都将失效。
- `chunkhash`: 根据不同的入口文件(Entry)进行依赖文件解析、构建对应的chunk，生成对应的哈希值，每个chunk 模块的 hash 值不一样。
- `contenthash`: 针对文件内容级别，只有自己模块的内容变了，那么 hash 值才改变

```js
module.exports = {
..
    output: {
        path: __dirname + "/build",
        filename: "bundle-[hash].js"
    },
   ...
};
```

使用无效缓存清理插件 [`clean-webpack-plugin`](https://github.com/johnagan/clean-webpack-plugin) 清理同名缓存

```powershell
npm install --save-dev clean-webpack-plugin
```

```js
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
                root: __dirname, // Default: root of your package
                verbose: true, // Write logs to console
                dry: false, // Default: false - remove files
                watch: false, // Default: false.  If true, remove files on recompile. 
                exclude: [ ], // // Good for not removing shared files from build directories.
                allowExternal: false, // Default: false - don't allow clean folder outside of the webpack root
                beforeEmit: false // perform clean just before files are emitted to the output dir or not
            }
        )
    ],
```