# Express.js 入门

## 安装

```console
> npm init
> npm install express --save-dev
```

## Express 应用生成器

```console
> npm install express-generator -g
> express --view=pug --git myapp
> cd myapp
> npm install
> npm start
```

访问 [http://localhost:3000/](http://localhost:3000/)

> 所有命令行参数

```console
> express -h

  Usage: express [options] [dir]

  Options:

    -h, --help          输出使用方法
        --version       输出版本号
    -e, --ejs           添加对 ejs 模板引擎的支持
        --hbs           添加对 handlebars 模板引擎的支持
        --pug           添加对 pug 模板引擎的支持
    -H, --hogan         添加对 hogan.js 模板引擎的支持
        --no-view       创建不带视图引擎的项目
    -v, --view <engine> 添加对视图引擎（view） <engine> 的支持 (ejs|hbs|hjs|jade|pug|twig|vash) （默认是 jade 模板引擎）
    -c, --css <engine>  添加样式表引擎 <engine> 的支持 (less|stylus|compass|sass) （默认是普通的 css 文件）
        --git           添加 .gitignore
    -f, --force         强制在非空目录下创建
```

## 路由 routing

### 路由的语法

```js
/*
 * app: Express 的一个实例
 * METHOD: HTTP 请求方法(小写)
 * PATH: 服务器路径
 * HANDLER: 路由匹配时的执行函数
 * http://www.expressjs.com.cn/en/4x/api.html#app.METHOD
 */
app.METHOD(PATH, HANDLER)
```

### 路由方法 `METHOD`

Express 路由方法是从 HTTP 方法派生出来的，包括 `GET`, `PUT`, `POST`, `DELETE`。除此之外，还有一个特殊的路由方法 `all`，用于在**所有 HTTP 请求方法**的路径上加载中间件函数。

> eg.

```js
app.get('/', function (req, res) {
  res.send('Hello World!')
})

app.post('/', function (req, res) {
  res.send('Got a POST request')
})

app.put('/user', function (req, res) {
  res.send('Got a PUT request at /user')
})

app.delete('/user', function (req, res) {
  res.send('Got a DELETE request at /user')
})

/*
 * 特殊的路由方法，在所有 HTTP 请求方法的路径上加载中间件函数
 */
app.all('/user', function (req, res) {
  res.send('Got a DELETE request at /user')
})
```

### 路由路径

**路由路径**定义可以进行请求的端点。路径路径可以是字符串，字符串模式或正则表达式。字符 `?`, `+`, `*` 和 `()` 是它们的正则表达式对应物的子集。连字符 `-` 和点 `.` 由字符串路径按字面解释。如果你需要在路径字符串中使用美元字符 `$`，需要将其包含在 `[]` 中。

> 查询字符串不是路径路径的一部分。

```js
// 匹配 abe, abcde
app.get('/ab(cd)?e', function (req, res) {
  res.send('ab(cd)?e')
})

// 匹配 abcd, abbcd, abbbcd...
app.get('/ab+cd', function (req, res) {
  res.send('ab+cd')
})

// 匹配 abcd, abxcd, abRANDOMcd, ab123cd...
app.get('/ab*cd', function (req, res) {
  res.send('ab*cd')
})

// 匹配任何包含 a 的路径
app.get(/a/, function (req, res) {
  res.send('/a/')
})

// 匹配已 fly 结尾的路径如 dragonfly, butterfly
app.get(/.*fly$/, function (req, res) {
  res.send('/.*fly$/')
})
```

### 路由参数

[参考](http://www.expressjs.com.cn/en/guide/routing.html)

### 路由处理程序 Handler

路径匹配时的回调函数，可以提供多个回调函数，其行为类似于中间件来处理请求。唯一的例外是这些回调可能会调用 `next('route')` 来绕过剩余的路由回调。可以使用此机制对路径施加**前置条件**，然后在没有理由继续当前路由的情况下将控制权传递给后续路由。

```js
app.get('/example/a', function (req, res) {
  res.send('Hello from A!')
})

app.get('/example/b', function (req, res, next) {
  console.log('the response will be sent by the next function ...')
  next()
}, function (req, res) {
  res.send('Hello from B!')
})

var cb0 = function (req, res, next) {
  console.log('CB0')
  next()
}
var cb1 = function (req, res, next) {
  console.log('CB1')
  next()
}
var cb2 = function (req, res) {
  res.send('Hello from C!')
}
app.get('/example/c', [cb0, cb1, cb2])

app.get('/example/c', [cb0, cb1, cb2], function (req, res, next) {
  console.log('the response will be sent by the next function ...')
  next()
}, function (req, res) {
  res.send('Hello from D!')
})
```

### 路由响应

向客户端发送响应，并终止**请求-响应周期**。如果没有从路由处理程序调用相关方法，则客户端请求将保持挂起状态。

> 响应方法

| 方法 | 描述 |
| ---- | --- |
| [`res.download()`](http://www.expressjs.com.cn/en/4x/api.html#res.download) | 提示下载文件 |
| [`res.end()`](http://www.expressjs.com.cn/en/4x/api.html#res.end) | 结束响应过程 |
| [`res.json()`](http://www.expressjs.com.cn/en/4x/api.html#res.json) | 发送 JSON 响应 |
| [`res.jsonp()`](http://www.expressjs.com.cn/en/4x/api.html#res.jsonp) | 发送支持 JSONP 的 JSON 响应 |
| [`res.redirect()`](http://www.expressjs.com.cn/en/4x/api.html#res.redirect) | 重定向请求 |
| [`res.render()`](http://www.expressjs.com.cn/en/4x/api.html#res.render) | 渲染视图模板 |
| [`res.send()`](http://www.expressjs.com.cn/en/4x/api.html#res.send) | 发送各种类型的响应 |
| [`res.sendFile()`](http://www.expressjs.com.cn/en/4x/api.html#res.sendFile) | 将文件作为八位字节流发送 |
| [`res.sendStatus()`](http://www.expressjs.com.cn/en/4x/api.html#res.sendStatus) | 设置响应状态代码并将其字符串表示形式作为响应主体发送 |

### 链式路由

可使用 `app.route(PATH)` 方法来创建一个链式路由。

```js
app.route('/book')
  .get(function (req, res) {
    res.send('Get a random book')
  })
  .post(function (req, res) {
    res.send('Add a book')
  })
  .put(function (req, res) {
    res.send('Update the book')
  })
```

### express.Router

使用 `express.Router` 类创建模块化，可安装的路由处理程序。
