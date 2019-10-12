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

## JS 实现类式继承

```js
// Shape - superclass
function Shape() {
  this.x = 0;
  this.y = 0;
}

// superclass method
Shape.prototype.move = function(x, y) {
  this.x += x;
  this.y += y;
  console.info('Shape moved.');
};
```

### 父类对象或 `prototype` 的继承

```js
/*************************************************************************
 * 优点:
 *    1. 正确设置原型链实现继承
 *    2. 父类实例属性得到继承，原型链查找效率提高，也能为一些属性提供合理的默认值
 * 缺点:
 *    1. 父类实例属性为引用类型时，不恰当地修改会导致所有子类被修改
 *    2. 创建父类实例作为子类原型时，可能无法确定构造函数需要的合理参数，这样提供
 *       的参数继承给子类没有实际意义，当子类需要这些参数时应该在构造函数中进行初
 *       始化和设置
 *    3. 继承应该是继承方法而不是属性，为子类设置父类实例属性应该是通过在子类构造
 *       函数中调用父类构造函数进行初始化
 *************************************************************************/
// subclass extends superclass
Rectangle.prototype = new Shape();

/*************************************************************************
 * 优点:
 *    1. 正确设置原型链实现继承
 * 缺点:
 *    1. 父类构造函数原型与子类相同。修改子类原型添加方法会修改父类
 *************************************************************************/
// or
// subclass extends superclass
Rectangle.prototype = Shape.prototype;

var rect = new Rectangle();
```

### [`Object.create`](https://developer.mozilla.org/en-us/docs/Web/JavaScript/Reference/Global_Objects/Object/create)

优点：能正确设置原型链且避免方法上面实现的缺点
缺点：`Object.create` 方法在 ES5 中引入，适配低版本浏览器应该考虑兼容性(IE8及以下)，polyfill 如下

```js
function create(obj) {
    if (Object.create) {
        return Object.create(obj);
    }

    function f() {};
    f.prototype = obj;
    return new f();
}
```

1. 单继承

    ```js
    // Rectangle - subclass
    function Rectangle() {
      Shape.call(this); // call super constructor.
    }

    // subclass extends superclass
    Rectangle.prototype = Object.create(Shape.prototype);

    //If you don't set Object.prototype.constructor to Rectangle,
    //it will take prototype.constructor of Shape (parent).
    //To avoid that, we set the prototype.constructor to Rectangle (child).
    Rectangle.prototype.constructor = Rectangle;

    var rect = new Rectangle();
    ```

2. 多继承，使用混入(mixins)的方式

    ```js
    function MyClass() {
      SuperClass.call(this);
      OtherSuperClass.call(this);
    }

    // inherit one class
    MyClass.prototype = Object.create(SuperClass.prototype);
    // mixin another
    Object.assign(MyClass.prototype, OtherSuperClass.prototype);
    // re-assign constructor
    MyClass.prototype.constructor = MyClass;

    MyClass.prototype.myMethod = function() {
      // do something
    };
    ```

## 用于拓展原型链的方法

[Ref:4 个用于拓展原型链的方法](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Inheritance_and_the_prototype_chain#%E6%80%BB%E7%BB%93%EF%BC%9A4_%E4%B8%AA%E7%94%A8%E4%BA%8E%E6%8B%93%E5%B1%95%E5%8E%9F%E5%9E%8B%E9%93%BE%E7%9A%84%E6%96%B9%E6%B3%95)

## JS 严格模式

ECMAScript 5 的严格模式是采用具有限制性 JavaScript 变体的一种方式，从而使代码显示地 脱离“马虎模式/稀松模式/懒散模式“（sloppy）模式。

1. 严格模式通过抛出错误来消除了一些原有静默错误。
    1. 严格模式下无法再意外创建全局变量。
    2. 严格模式会使引起静默失败(silently fail)抛出异常。
    3. 严格模式下, 试图删除不可删除的属性时会抛出异常。
    4. 在严格模式下，对象重名属性被认为是语法错误(这个问题在 ECMAScript6 中已经不复存在)。
    5. 严格模式要求函数的参数名唯一。
    6. 严格模式禁止八进制数字语法(ECMAScript并不包含八进制语法, 但所有的浏览器都支持以零`0`头的八进制语法: `0644 === 420` 还有 `"\045" === "%"`.在 ECMAScript 6 中支持为一个数字加 `0o` 的前缀来表示八进制数)。
    7. ECMAScript 6中的严格模式禁止设置 primitive 的属性.不采用严格模式,设置属性将会简单忽略(no-op),采用严格模式,将抛出 TypeError 错误。
2. 严格模式修复了一些导致 JavaScript 引擎难以执行优化的缺陷：有时候，相同的代码，严格模式可以比非严格模式下运行得更快。
    1. 严格模式禁用 `with`.  `with` 所引起的问题是块内的任何名称可以映射(map)到 `with` 传进来的对象的属性, 也可以映射到包围这个块的作用域内的变量(甚至是全局变量), 这一切都是在运行时决定的: 在代码运行之前是无法得知的。
    2. 严格模式下的 `eval` 不再为上层范围(surrounding scope,注:包围 `eval` 代码块的范围)引入新变量。
    3. 严格模式禁止删除声明变量。`delete name` 在严格模式下会引起语法错误。
    4. 严格模式下名称 `eval` 和 `arguments` 不能通过程序语法被绑定(be bound)或赋值。

        ```js
        // 以下操作会报语法错误
        "use strict";
        eval = 17;
        arguments++;
        ++eval;
        var obj = { set p(arguments) { } };
        var eval;
        try { } catch (arguments) { }
        function x(eval) { }
        function arguments() { }
        var y = function eval() { };
        var f = new Function("arguments", "'use strict'; return 17;");
        ```

    5. 严格模式下，参数的值不会随 `arguments` 对象的值的改变而变化，函数的 `arguments` 对象会保存函数被调用时的原始参数。(在正常模式下，对于第一个参数是 `arg` 的函数，对 `arg` 赋值时会同时赋值给 `arguments[0]`，反之亦然)
    6. 严格模式下不再支持 `arguments.callee`。
    7. 在严格模式下通过 `this` 传递给一个函数的值不会被强制转换为一个对象。
    8. 在严格模式函数或用于调用它们的 `arguments` 对象上，无法访问 `caller`, `callee` 和  `arguments` 属性
3. 严格模式禁用了在 ECMAScript 的未来版本中可能会定义的一些语法。
    1. 在严格模式中，一部分字符变成了保留的关键字。这些字符包括 `implements`, `interface`, `let`, `package`, `private`, `protected`, `public`, `static` 和 `yield`
    2. 严格模式禁止了不在脚本或者函数层面上的函数声明
