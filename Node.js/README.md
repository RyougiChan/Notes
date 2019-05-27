# Node.js 入门

JavaScript 最早运行在浏览器中，然而浏览器只是提供了一个上下文，它定义了使用 JavaScript 可以做什么，但并没有“说”太多关于 JavaScript 语言本身可以做什么。事实上，JavaScript 是一门“完整”的语言：它可以使用在不同的上下文中，Node.js 事实上就是另外一种上下文，它允许在后端（脱离浏览器环境）运行 JavaScript 代码。

要实现在后台运行 JavaScript 代码，代码需要先被解释然后正确的执行。Node.js 的原理正是如此，它使用了 Google 的 V8 虚拟机来解释和执行JavaScript代码。

## 安装

参考 [Node.js Github](https://github.com/nodejs/node)

## Hello World

> helloworld.js

```js
console.log("Hello World");
```

> cmd

```console
$ node helloworld.js
Hello World!
```

## 一个完整的基于 Node.js 的 web 应用

### 需求分析

- 用户可以通过浏览器使用我们的应用。
- 当用户请求 `http://domain/start` 时，可以看到一个欢迎页面，页面上有一个文件上传的表单。
- 用户可以选择一个图片并提交表单，随后文件将被上传到 `http://domain/upload`，该页面完成上传后会把图片显示在页面上。

### 应用模块分析

- 我们需要提供 Web 页面，因此需要一个 **HTTP 服务器**
- 对于不同的请求，根据请求的 URL，我们的服务器需要给予不同的响应，因此我们需要一个**路由**，用于把请求对应到请求处理程序（request handler）
- 当请求被服务器接收并通过路由传递之后，需要可以对其进行处理，因此我们需要最终的**请求处理程序**
- 路由还应该能处理 POST 数据，并且把数据封装成更友好的格式传递给请求处理入程序，因此需要**请求数据处理功能**
- 我们不仅仅要处理 URL 对应的请求，还要把内容显示出来，这意味着我们需要一些**视图**逻辑供请求处理程序使用，以便将内容发送给用户的浏览器
- 最后，用户需要上传图片，所以我们需要**上传处理功能**来处理这方面的细节

### 实现细节

1. HTTP 服务器

    > server.js

    ```js
    const http = require('http');

    http.createServer((req, res) => {
        res.writeHead(200, {"Content-Type": "text/plain"});
        res.write('Hello World');
        res.end();
    }).listen(8888);
    ```

    > 基于**事件驱动**的回调

    Node.js 服务器运行在一个单进程中，它使用 `requestListener` 方法来处理请求，这个方法在有相应事件发生时调用这个函数来进行回调。

    > 服务器模块 server.js

    ```js
    const http = require('http');

    const start = () => {
        http.createServer((req, res) => {
            console.log('Request Received');
            res.writeHead(200, {"Content-Type": "text/plain"});
            res.write('Hello World');
            res.end();
        }).listen(8888);
        console.log('Server Started');
    };

    exports.start = start;
    ```

    > 主文件 index.js

    ```js
    const server = require('./server');

    server.start();
    ```

2. 请求的**路由**

    > 使用依赖注入的方式添加路由模块
    > router.js

    ```js
    const route = (pathname) => {
        console.log('route for', pathname);
    };

    exports.route = route;
    ```

    > route 传递给 server.js 的 `start` 函数

    ```js
    // ...
    const start = (route) => {
        // ...
    };
    ```

    > 主文件传参 index.js

    ```js
    const server = require('./server');
    const router = require('./router');

    server.start(router.route);
    ```

3. **处理程序** requestHandlers 的模块

    > requestHandlers.js

    ```js
    const start = () => {
        console.log("Request handler 'start' was called.");
    };

    const upload = () => {
        console.log("Request handler 'upload' was called.");
    };

    exports.start = start;
    exports.upload = upload;
    ```

    > index.js 构建键值映射

    ```js
    const server = require('./server');
    const router = require('./router');
    const requestHanders = require('./requestHanders');

    let handle = {};
    handle["/"] = requestHanders.start;
    handle["/start"] = requestHanders.start;
    handle["/upload"] = requestHanders.upload;

    server.start(router.route, handle);
    ```

    > server.js 传入 handle 键值集

    ```js
    // ...
    const start = (route, handle) => {
        http.createServer((req, res) => {
            let pathname = url.parse(req.url).pathname;
            console.log('Request Received, pathname: ', pathname);
            route(handle, pathname);
            //...
        }
    };
    ```

    > router.js 处理映射

    ```js
    const route = (handle, pathname) => {
        console.log('route for', pathname);
        if (typeof handle[pathname] === 'function') {
            handle[pathname]();
        } else {
            console.log("No request handler found for " + pathname);
        }
    };

    exports.route = route;
    ```