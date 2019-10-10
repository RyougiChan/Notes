# JS

## cookie|session|localStorage|sessionStorage

1. `cookie`
    解决 http 的无状态问题，是客户端保存用户信息的一种机制，用来记录用户的一些信息，来实现 session的跟踪。 cookie 的同源是域名相同，忽略协议和端口，不可跨域。它的大小限制为4KB左右。浏览器不能保存超过 300 个 cookie，单个服务器不能超过 20 个。

    | 属性名 |     意义        |
    | ----- |     ---        |
    | name/value | 以 key/value 的形式存在            |
    | comment    | 说明该 cookie 的用处                   |
    | domain     | 可以访问该 cookie 的域名          |
    | Expires/maxAge | cookie 失效时间。负数:临时 cookie，关闭浏览器就失效；`0`:表示删除 cookie，默认为 `-1`|
    | path       | 可以访问此 cookie 的页面路径 |
    | size       | cookie 的大小           |
    | secure     | 是否以 https 协议传输                  |
    | version    | 该 cookie 使用的版本号，`0` 遵循 Netscape 规范，大多数用这种，`1` 遵循W3C规范         |
    | HttpOnly   | 此属性为 `true` 时只有在 http 请求头中会带有此 cookie 的信息，不能通过 `document.cookie` 来访问此 cookie |

2. `session`
    session 是在服务端保存的一个数据结构，用来跟踪用户的状态，这个数据可以保存在集群、数据库、文件中。 session 的运行依赖 session id，而 session id 是存在 cookie 中。如果禁用 cookie ，使用**URL 重写**技术来进行会话跟踪，在 URL 中传递 session id。

3. `localStorage`
    HTML5 标准中新加入的技术，用于持久化的本地存储，除非主动删除数据，否则数据是永远不会过期的。

4. `sessionStorage`
    用于本地存储一个会话(session)中的数据，这些数据只有在同一个会话中的页面才能访问并且当会话结束后数据也随之销毁。

`cookie`/`localStorage`/`sessionStorage` 特性对比表

| 特性 | `cookie` | `localStorage` | `sessionStorage` |
| --- | -------- | -------------- | ---------------- |
| 数据生命周期 | 可设置失效时间，默认是浏览器关闭销毁 | 除非被清除，否则永久保存 | 仅在当前会话下有效，关闭页面或浏览器后被清除 |
| 可存数据大小 | ≈4k | ≈5M | ≈5M |
| 与服务器通信 | 每次都会携带在 HTTP 头中，若使用 cookie 保存过多数据会有性能问题 | 仅在客户端中保存，不参与服务器通信 | 仅在客户端中保存，不参与服务器通信 |
| 使用方法    | 原生 cookie 接口不友好，[`document.cookie`](https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie) | [`[window.]localStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage) | [`[window.]sessionStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage) |

## Element.getAttribute(attributeName) 和 Element.attributeName

[1]: Element.getAttribute(attributeName), [2]: Element.attributeName

| [1] | [2] |
| --- | --- |
| 标准 DOM 操作文档元素属性的方法，**具有通用性**，可在**任意文档**上使用，返回元素在**源文件**中设置的属性 | 在 **HTML 文档**中访问浏览器解析元素后生成对应对象的标准特性对应的属性，无法访问没有对应特性的属性 |
| 返回值类型为 `string`/`null`/`''` | 返回值类型可为 `string`/`true|flase`/`object`/`undefined`/`number` 等 |

[1] 通过 `setAttribute('value', '')` 设置 `<input>` 的属性值不会改变 `<input>` 的 `value` 值。
[2] 无法感知部分布尔值如 `<input hidden />`，需要使用 `hasAttribute('hidden')` 判断。

## JS 的数据类型(最新的ECMAScript标准)

  1. Boolean
  2. Null
  3. Undefined
  4. Number
  5. BigInt
  6. String
  7. Symbol
  8. [Object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures)
