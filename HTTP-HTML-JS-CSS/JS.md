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

## JS 事件模型

[ref](https://www.quirksmode.org/js/events_order.html)

1. 两大事件模型
    1. 事件捕获

        ```plain
                    ||
        ---------------||-----------------
        | element1     ||                |
        |   -----------||-----------     |
        |   |element2  \/          |     |
        |   ------------------------     |
        |        Event CAPTURING         |
        ----------------------------------
        ```

    2. 事件冒泡

        ```plain
                       /\
        ---------------||-----------------
        | element1     ||                |
        |   -----------||-----------     |
        |   |element2  ||          |     |
        |   ------------------------     |
        |        Event BUBBLING          |
        ----------------------------------
        ```

        阻止事件冒泡

        ```js
        // 1. for microsoft model
        window.event.cancelBubble = true

        // 2. for W3C model
        e.stopPropagation()

        // eg.
        function doSomething(e)
        {
            if (!e) var e = window.event;
            e.cancelBubble = true;
            if (e.stopPropagation) e.stopPropagation();
        }
        ```

2. W3C 事件模型

> W3C 事件模型中发生的任何事件都**首先被捕获**，直到到达目标元素，**然后再次冒泡**。

```plain
                 ||  /\
-----------------||--||-----------------
| element1       ||  ||                |
|   -------------||--||-----------     |
|   |element2    \/  ||          |     |
|   ------------------------------     |
|        W3C event model               |
----------------------------------------
```

## focus/blur 与 focusin/focusout

`focus/blur` 不会冒泡而 `focusin/focusout` 冒泡，如果需要实现事件委托，可通过在支持的浏览器上使用 `focusin/focusout` 事件 (除了 Firefox 之外的所有浏览器)，或者通过使用 `focus/blur` 并设置 `addEventListener` 的参数 `useCapture` 值为 `true`

```js
const form = document.getElementById('form');

form.addEventListener('focus', (event) => {
    event.target.style.background = 'pink';
}, true);

form.addEventListener('blur', (event) => {
    event.target.style.background = '';
}, true);
```

## mouseenter/mouseleave 与 mouseover/mouseout

| `mouseover/mouseout` | `mouseenter/mouseleave` |
| ------------------ | --------------------- |
| 标准事件，所有浏览器都支持 | IE5.5 引入的特有事件后来被 DOM3 标准采纳，现代标准浏览器也支持 |
| 冒泡事件(需要为多个元素监听鼠标移入/出事件时，推荐使用 `mouseover/mouseout` 托管，提高性能) | 非冒泡事件 |

1. `event.target` 表示发生移入/出的元素，`event.relatedTarget` 对应移出/入的元素
2. 旧 IE 中 `event.srcElement` 表示发生移入/出的元素，`event.toElement` 表示移出的目标元素，`event.fromElement` 表示移入时的来源元素

## JS 闭包

> JavaScript 中的函数会形成[闭包](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)。闭包是由**函数**以及创建该函数的**词法环境**组合而成。这个环境包含了这个闭包创建时所能访问的**所有局部变量**。通常使用只有一个方法的对象的地方，都可以使用闭包。

```js
function makeFunc() {
    var name = "Mozilla";
    function displayName() {
        alert(name);
    }
    return displayName;
}

var myFunc = makeFunc();
myFunc(); // Mozolla
```

应用

1. 回调函数

    ```html
    <a href="#" id="size-12">12</a>
    <a href="#" id="size-14">14</a>
    <a href="#" id="size-16">16</a>
    ```

    ```js
    function makeSizer(size) {
    return function() {
        document.body.style.fontSize = size + 'px';
    };
    }

    var size12 = makeSizer(12);
    var size14 = makeSizer(14);
    var size16 = makeSizer(16);

    document.getElementById('size-12').onclick = size12;
    document.getElementById('size-14').onclick = size14;
    document.getElementById('size-16').onclick = size16
    ```

2. 模拟私有方法(同时提供了管理全局命名空间的强大能力)

```js
// 模块模式(module pattern):使用闭包来定义公共函数，并令其可以访问私有函数和变量。
var makeCounter = function() {
  var privateCounter = 0;
  function changeBy(val) {
    privateCounter += val;
  }
  return {
    increment: function() {
      changeBy(1);
    },
    decrement: function() {
      changeBy(-1);
    },
    value: function() {
      return privateCounter;
    }
  }  
};

var Counter1 = makeCounter();
var Counter2 = makeCounter();
console.log(Counter1.value()); /* logs 0 */
Counter1.increment();
Counter1.increment();
console.log(Counter1.value()); /* logs 2 */
Counter1.decrement();
console.log(Counter1.value()); /* logs 1 */
console.log(Counter2.value()); /* logs 0 */
```

**性能考量:**如果不是某些特定任务需要使用闭包，在其它函数中创建函数是不明智的，因为**闭包在处理速度和内存消耗方面对脚本性能具有负面影响**。

> 示例1:

```js
function MyObject(name, message) {
  this.name = name.toString();
  this.message = message.toString();
  // 此处形成闭包
  // 在创建新的对象或者类时，方法通常应该关联于对象的原型，而不是定义到对象的构造器中
  // 每次构造器被调用时，方法都会被重新赋值一次
  this.getName = function() {
    return this.name;
  };

  this.getMessage = function() {
    return this.message;
  };
}
```

> 示例2:

```js
function MyObject(name, message) {
  this.name = name.toString();
  this.message = message.toString();
}
// 分离出来，避免使用闭包
// 继承的原型可以为所有对象共享，不必在每一次创建对象时定义方法
MyObject.prototype = {
  getName: function() {
    return this.name;
  },
  getMessage: function() {
    return this.message;
  }
};
```

> 示例3:

```js
// 示例2的改进:不建议重新定义原型
function MyObject(name, message) {
  this.name = name.toString();
  this.message = message.toString();
}

MyObject.prototype.getName = function() {
  return this.name;
};
MyObject.prototype.getMessage = function() {
  return this.message;
};
```
