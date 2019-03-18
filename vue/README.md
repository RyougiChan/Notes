# Vue 学习笔记

## [安装](https://cn.vuejs.org/v2/guide/installation.html)

- 直接用 `<script>` 引入

[下载开发版](https://vuejs.org/js/vue.js)
[下载生产版](https://vuejs.org/js/vue.min.js)

CDN

```html
<!-- 最新版本 -->
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
<!-- 生产环境推荐链接到一个明确的版本号和构建文件 -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.7/dist/vue.js"></script>

<!-- 原生 ES Modules -->
<script type="module">
  import Vue from 'https://cdn.jsdelivr.net/npm/vue@2.6.7/dist/vue.esm.browser.js'
</script>
```

- NPM

```shell
# 最新稳定版
$ npm install --save-dev vue
```

- [命令行工具 (CLI)](https://cli.vuejs.org/)

```shell
# 最新稳定版
$ npm install --save-dev vue-cli
```

## 基础

- [Vue 的生命周期](https://cn.vuejs.org/v2/api/#%E9%80%89%E9%A1%B9-%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E9%92%A9%E5%AD%90) `beforeCreate/created、beforeMount/mounted、beforeUpdate/updated、beforeDestory/destoryed`

![Vue 生命周期](https://cn.vuejs.org/images/lifecycle.png)

> 所有的生命周期钩子自动绑定 `this` 上下文到实例中，因此你可以访问数据，对属性和方法进行运算。这意味着你不能使用箭头函数来定义一个生命周期方法 (例如 `created: () => this.fetchTodos()`)。这是因为箭头函数绑定了父上下文，因此 `this` 与你期待的 `Vue` 实例不同，`this.fetchTodos` 的行为未定义。

### 指令

- [Vue 指令](https://cn.vuejs.org/v2/api/#%E6%8C%87%E4%BB%A4)
  - `v-text` 更新元素的 `textContent`

  ```html
  <span v-text="msg"></span>
  <!-- 和下面的一样 -->
  <span>{{msg}}</span>
  ```

  - `v-html` 更新元素的 `innerHTML`

  ```html
  <div v-html="html"></div>
  ```

  - `v-show` 根据表达式之真假值，切换元素的 display CSS 属性(总是渲染)。[条件渲染(伪物) v-show](https://cn.vuejs.org/v2/guide/conditional.html#v-show)

  `v-show` 不支持 `<template>` 元素，也不支持 `v-else`

  `v-if` 的切换开销大，`v-show` 则是初始渲染开销大，频繁切换使用 `v-show`，运行时经常改变则使用 `v-if`

  ```html
  <h1 v-show="ok">Hello!</h1>
  ```

  - `v-if`, `v-else-if`(Vue2.1.0+), `v-else` 根据表达式的值的真假条件渲染元素(`v-if` 是惰性的，初始为假)。在切换时元素及它的数据绑定/组件被销毁并重建。如果元素是 `<template>` ，将提出它的内容作为条件块。[条件渲染](https://cn.vuejs.org/v2/guide/conditional.html)

  当和 `v-if` 一起使用时，`v-for` 的优先级比 `v-if` 更高。详见列表渲染教程

  ```html
    <div v-if="type === 'A'">
    A
    </div>
    <div v-else-if="type === 'B'">
    B
    </div>
    <div v-else-if="type === 'C'">
    C
    </div>
    <div v-else>
    Not A/B/C
    </div>
  ```

  [用 key 管理可复用的元素](https://cn.vuejs.org/v2/guide/conditional.html#%E7%94%A8-key-%E7%AE%A1%E7%90%86%E5%8F%AF%E5%A4%8D%E7%94%A8%E7%9A%84%E5%85%83%E7%B4%A0): Vue 会尽可能高效地渲染元素，通常会复用已有元素而不是从头开始渲染，使用 `key` 来表达元素是完全独立的，不要复用。

  - `v-for` 基于源数据多次渲染元素或模板块。此指令之值，必须使用特定语法 `alias in expression` ，为当前遍历的元素提供别名

    - 从 Vue 2.6 起，`v-for` 也可以在实现了可迭代协议的值上使用，包括原生的 `Map` 和 `Set`。不过应该注意的是 Vue 2.x 目前并不支持可响应的 `Map` 和 `Set` 值，所以无法自动探测变更。
    - `v-for` 和 `<template>` 搭配可减少渲染次数
    - `v-for` 和自定义组件使用时，需要使用 `props` 来传递值
    - 当 Vue.js 用 `v-for` 正在更新已渲染过的元素列表时，它默认用[“就地复用”](https://cn.vuejs.org/v2/guide/list.html#key)策略。如果数据项的顺序被改变，Vue 将不会移动 DOM 元素来匹配数据项的顺序，而是简单复用此处每个元素，并且确保它在特定索引下显示已被渲染过的每个元素。这个默认的模式是高效的，但是只适用于**不依赖子组件状态或临时 DOM 状态 (例如：表单输入值) 的列表渲染输出**。建议尽可能在使用 `v-for` 时提供 `key`，除非遍历输出的 DOM 内容非常简单，或者是刻意依赖默认行为以获取**性能上的提升**。

  ```html
    <div v-for="item in items">
    {{ item.text }}
    </div>
    <!-- 或 -->
    <div v-for="(item, index) in items"></div>
    <div v-for="(val, key) in object"></div>
    <div v-for="(val, key, index) in object"></div>

    <!-- v-for 默认行为试着不改变整体，而是替换元素。迫使其重新排序的元素，你需要提供一个 key 的特殊属性： -->
    <div v-for="item in items" :key="item.id">
        {{ item.text }}
    </div>
  ```

  - `v-on`
  
    缩写 `@` 绑定事件 **监听器**。事件类型由参数指定。表达式可以是一个方法的名字或一个内联语句，如果没有修饰符也可以省略。用在普通元素上时，只能监听原生 DOM 事件。用在自定义元素组件上时，也可以监听子组件触发的自定义事件。在监听原生 DOM 事件时，方法以事件为唯一的参数。如果使用内联语句，语句可以访问一个 `$event` 属性：`v-on:click="handle('ok', $event)"`。
    [修饰符](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener)
    - `.stop` 调用 `event.stopPropagation()`。
    - `.prevent` 调用 `event.preventDefault()`。
    - `.capture` 添加事件侦听器时使用 `capture` 模式。
    - `.self` 只当事件是从侦听器绑定的元素本身触发时才触发回调。
    - `.{keyCode | keyAlias}` 只当事件是从特定键触发时才触发回调。
    - `.native` 监听组件根元素的原生事件。
    - `.once` (2.1.4+) 只触发一次回调。
    - `.left` (2.2.0+) 只当点击鼠标左键时触发。
    - `.right` (2.2.0+) 只当点击鼠标右键时触发。
    - `.middle` (2.2.0+) 只当点击鼠标中键时触发。
    - `.passive` (2.3.0+) 以 `{ passive: true }` 模式添加侦听器。

  ```html
    <!-- 方法处理器 -->
    <button v-on:click="doThis"></button>

    <!-- 动态事件 (2.6.0+) -->
    <button v-on:[event]="doThis"></button>

    <!-- 内联语句 -->
    <button v-on:click="doThat('hello', $event)"></button>

    <!-- 缩写 -->
    <button @click="doThis"></button>

    <!-- 动态事件缩写 (2.6.0+) -->
    <button @[event]="doThis"></button>

    <!-- 停止冒泡 -->
    <button @click.stop="doThis"></button>

    <!-- 阻止默认行为 -->
    <button @click.prevent="doThis"></button>

    <!-- 阻止默认行为，没有表达式 -->
    <form @submit.prevent></form>

    <!--  串联修饰符 -->
    <button @click.stop.prevent="doThis"></button>

    <!-- 键修饰符，键别名 -->
    <!-- 有一些按键 (.esc 以及所有的方向键) 在 IE9 中有不同的 key 值, 如果你想支持 IE9，这些内置的别名应该是首选。 -->
    <input @keyup.enter="onEnter">

    <!-- 键修饰符，键代码 -->
    <!-- keyCode 的事件用法已经被废弃了并可能不会被最新的浏览器支持 -->
    <input @keyup.13="onEnter">

    <!-- 点击回调只会触发一次 -->
    <button v-on:click.once="doThis"></button>

    <!-- 对象语法 (2.4.0+) -->
    <button v-on="{ mousedown: doThis, mouseup: doThat }"></button>
  ```

  - `v-bind` 缩写：`:`. 动态地绑定一个或多个特性，或一个组件 `prop` 到表达式。

    修饰符：
    - `.prop` 被用于绑定 DOM 属性 (`property`)。[差别](https://stackoverflow.com/questions/6003819/properties-and-attributes-in-html#answer-6004028)
    - `.camel` (2.1.0+) 将 `kebab-case` 特性名转换为 `camelCase`.
    - [`.sync`](https://cn.vuejs.org/v2/guide/components-custom-events.html#sync-%E4%BF%AE%E9%A5%B0%E7%AC%A6) (2.3.0+) 语法糖，会扩展成一个更新父组件绑定值的 `v-on` 侦听器。

  ```html
    <!-- 绑定一个属性 -->
    <img v-bind:src="imageSrc">

    <!-- 动态特性名 (2.6.0+) -->
    <button v-bind:[key]="value"></button>

    <!-- 缩写 -->
    <img :src="imageSrc">

    <!-- 动态特性名缩写 (2.6.0+) -->
    <button :[key]="value"></button>

    <!-- 内联字符串拼接 -->
    <img :src="'/path/to/images/' + fileName">

    <!-- class 绑定 -->
    <div :class="{ red: isRed }"></div>
    <div :class="definedObject"></div>
    <div :class="[classA, classB]"></div>
    <div :class="[classA, { classB: isB, classC: isC }]">

    <!-- style 绑定 -->
    <div :style="{ fontSize: size + 'px' }"></div>
    <div :style="[styleObjectA, styleObjectB]"></div>
    <!-- v-bind:style可以使用多重值的形式 -->
    <div :style="display:['-webkit-box','-ms-flexbox', 'flex']"></div>

    <!-- 绑定一个有属性的对象 -->
    <div v-bind="{ id: someProp, 'other-attr': otherProp }"></div>

    <!-- 通过 prop 修饰符绑定 DOM 属性 -->
    <div v-bind:text-content.prop="text"></div>

    <!-- prop 绑定。“prop”必须在 my-component 中声明。-->
    <my-component :prop="someThing"></my-component>

    <!-- 通过 $props 将父组件的 props 一起传给子组件 -->
    <child-component v-bind="$props"></child-component>

    <!-- XLink -->
    <svg><a :xlink:special="foo"></a></svg>
  ```

  [Class 和 Style 的绑定](https://cn.vuejs.org/v2/guide/class-and-style.html)

  - `v-model` 在表单控件或者组件上创建[双向绑定](https://cn.vuejs.org/v2/guide/forms.html)。
    仅限于以下使用：
    - `<input>`
    - `<select>`
    - `<textarea>`
    - [components](https://cn.vuejs.org/v2/guide/components-custom-events.html#%E5%B0%86%E5%8E%9F%E7%94%9F%E4%BA%8B%E4%BB%B6%E7%BB%91%E5%AE%9A%E5%88%B0%E7%BB%84%E4%BB%B6)

    修饰符：
    - [`.lazy`](https://cn.vuejs.org/v2/guide/forms.html#lazy) 取代 `input` 监听 `change` 事件
    - [`.number`](https://cn.vuejs.org/v2/guide/forms.html#number) 输入字符串转为有效的数字
    - [`.trim`](https://cn.vuejs.org/v2/guide/forms.html#trim) 输入首尾空格过滤

  ```html
    <input v-model="message" placeholder="edit me">
    <p>Message is: {{ message }}</p>
  ```

  **Notice**: `v-model` 会忽略所有表单元素的 `value`、`checked`、`selected` 特性的初始值而总是将 Vue 实例的数据作为数据来源。你应该通过 JavaScript 在组件的 `data` 选项中声明初始值。

  - [`v-slot`](https://github.com/vuejs/rfcs/blob/master/active-rfcs/0001-new-slot-syntax.md) (2.6.0+) 缩写：`#`，提供具名插槽或需要接收 `prop` 的插槽。
    限用于
    - `<template>`
    - 组件 (对于一个单独的带 `prop` 的默认插槽)

  ```html
  <!-- 具名插槽 -->
  <foo>
    <template v-slot:header>
      <div class="header"></div>
    </template>

    <template v-slot:body>
      <div class="body"></div>
    </template>

    <template v-slot:footer>
      <div class="footer"></div>
    </template>
  </foo>

  <!-- 接收 prop 的具名插槽 -->
  <infinite-scroll>
    <template v-slot:item="slotProps">
      <div class="item">
        {{ slotProps.item.text }}
      </div>
    </template>
  </infinite-scroll>

  <!-- 接收 prop 的默认插槽，使用了解构 -->
  <mouse-position v-slot="{ x, y }">
    Mouse position: {{ x }}, {{ y }}
  </mouse-position>
  ```

  - `v-pre` 跳过这个元素和它的子元素的编译过程。可以用来显示原始 `Mustache` 标签。跳过大量没有指令的节点会加快编译。

  ```html
  <span v-pre>{{ this will not be compiled }}</span>
  ```

  - `v-cloak` 这个指令保持在元素上直到关联实例结束编译。和 CSS 规则如 `[v-cloak] { display: none }` 一起用时，这个指令可以隐藏未编译的 `Mustache` 标签直到实例准备完毕。

  ```html
  <div v-cloak>
    {{ message }}
  </div>
  ```

  ```css
  [v-cloak] {
    display: none;
  }
  ```

  - `v-once` 只渲染元素和组件一次。随后的重新渲染，元素/组件及其所有的子节点将被视为静态内容并跳过。

  ```html
  <!-- 单个元素 -->
  <span v-once>This will never change: {{msg}}</span>
  <!-- 有子元素 -->
  <div v-once>
    <h1>comment</h1>
    <p>{{msg}}</p>
  </div>
  <!-- 组件 -->
  <my-component v-once :comment="msg"></my-component>
  <!-- `v-for` 指令-->
  <ul>
    <li v-for="i in list" v-once>{{i}}</li>
  </ul>
  ```

### 特殊特性

- `is` 值：`string | Object (组件的选项对象)`

用于动态组件且基于 [DOM 内模板的限制](https://vuejs.org/v2/guide/components.html#DOM-Template-Parsing-Caveats)来工作。

```html
<!-- 当 `currentView` 改变时，组件也跟着改变 -->
<component v-bind:is="currentView"></component>

<!-- 这样做是有必要的，因为 `<my-row>` 需要放在一个`<table>` 内才会被挂载，类似的还有 `li` 元素需要放在 `<ul>` 中才能生效，这样可以避开一些潜在的浏览器解析错误 -->
<table>
  <tr is="my-row"></tr>
</table>
```

### vue 自定义组件

> 组件声明格式：组件名大小写使用 `kebab-case` 或 `PascalCase`。每个组件必须只有一个根元素，否则 Vue 会显示错误 `every component must have a single root element`

```js
// 全局注册
// 通过 Vue.component() 全局注册的组件可在其被注册后的任何通过 new Vue() 创建的实例所使用，包含其组件树中的所有组件
Vue.component('ComponentName',{
  data: function() {
    return {
      name: 'yuko',
    };
  },
  props:['p1','p2'],
  template: '<li>{{ name }} {{ p1 }}</li>'
});

// 局部注册
var ComponentA = { /* ... */ }
var ComponentB = { /* ... */ }

new Vue({
  el: '#app',
  components: {
    'component-a': ComponentA,
    'component-b': ComponentB
  }
});
```

注意：

- `data` 必须是一个函数，以实现每个实例可以维护一份被返回对象的独立的拷贝
- 局部注册的组件在其子组件中[不可用](https://cn.vuejs.org/v2/guide/components-registration.html#%E5%B1%80%E9%83%A8%E6%B3%A8%E5%86%8C)

> Prop

- 当你使用 DOM 中的模板时，`camelCase` (驼峰命名法) 的 `prop` 名需要使用其等价的 `kebab-case` (短横线分隔命名) 命名。(使用字符串模板，不存在此限制)
- 为了定制 `prop` 的验证方式，你可以为 `props` 中的值提供一个带有验证需求的对象，而不是一个字符串数组

```js
// 数组形式
props: ['title', 'likes', 'isPublished', 'commentIds', 'author']

// 对象形式
// Prop 验证
props: {
    // 基础的类型检查 (`null` 和 `undefined` 会通过任何类型验证)
    propA: Number,
    // 多个可能的类型
    propB: [String, Number],
    // 必填的字符串
    propC: {
      type: String,
      required: true
    },
    // 带有默认值的数字
    propD: {
      type: Number,
      default: 100
    },
    // 带有默认值的对象
    propE: {
      type: Object,
      // 对象或数组默认值必须从一个工厂函数获取
      default: function () {
        return { message: 'hello' }
      }
    },
    // 自定义验证函数
    propF: {
      validator: function (value) {
        // 这个值必须匹配下列字符串中的一个
        return ['success', 'warning', 'danger'].indexOf(value) !== -1
      }
    }
  }
```

- 传递静态或动态 Prop

传递 Prop 的值类型可以是任何类型的值，如 `String`, `Number`, `Boolean`, `Array`. `Object` 等

```html
<!-- 静态赋值 -->
<blog-post title="My journey with Vue"></blog-post>

<!-- 动态赋予一个变量的值 -->
<blog-post v-bind:title="post.title"></blog-post>

<!-- 动态赋予一个复杂表达式的值 -->
<blog-post
  v-bind:title="post.title + ' by ' + post.author.name"
></blog-post>
```

当需要使用对象的多个属性时，单独传参显得比较复杂时可以重构如下：

```html
<!-- 需要使用对象的多个属性 -->
<blog-post
  v-for="post in posts"
  v-bind:key="post.id"
  v-bind:title="post.title"
  v-bind:content="post.content"
  v-bind:publishedAt="post.publishedAt"
  v-bind:comments="post.comments"
></blog-post>

<!-- 接受一个单独的 post prop -->
<blog-post
  v-for="post in posts"
  v-bind:key="post.id"
  v-bind:post="post"
></blog-post>
```

```js
// 需要使用对象的多个属性
Vue.component('blog-post', {
  props: ['title', 'content'],
  template: `
    <div class="blog-post">
      <h3>{{ title }}</h3>
      <div v-html="content"></div>
    </div>
  `
})

// 接受一个单独的 post prop
Vue.component('blog-post', {
  props: ['post'],
  template: `
    <div class="blog-post">
      <h3>{{ post.title }}</h3>
      <div v-html="post.content"></div>
    </div>
  `
})
```

- 单向数据流
  所有的 `prop` 都使得其父子 `prop` 之间形成了一个**单向下行**绑定：父级 `prop` 的更新会向下流动到子组件中，但是反过来则不行。每次父级组件发生更新时，子组件中所有的 `prop` 都将会刷新为最新的值。这意味着 **不应该** 在一个子组件内部改变 `prop`。以下是两种常见的试图改变一个 `prop` 的情形：
  - 这个 `prop` 用来传递一个初始值；这个子组件接下来希望将其作为一个本地的 `prop` 数据来使用。

  ```js
  // 最好定义一个本地的 data 属性并将这个 prop 用作其初始值
  props: ['initialCounter'],
  data: function () {
    return {
      counter: this.initialCounter
    }
  }
  ```

  - 这个 prop 以一种原始的值传入且需要进行转换。

  ```js
  // 最好使用这个 prop 的值来定义一个计算属性
  props: ['size'],
  computed: {
    normalizedSize: function () {
      return this.size.trim().toLowerCase()
    }
  }
  ```

> 监听子组件事件

```html
<blog-post
  ...
  v-on:enlarge-text="postFontSize += 0.1"
></blog-post>

<button v-on:click="$emit('enlarge-text')">
  Enlarge text
</button>

<!-- 使用事件抛出一个值 -->
<button v-on:click="$emit('enlarge-text', 0.1)">
  Enlarge text
</button>

<blog-post
  ...
  v-on:enlarge-text="postFontSize += $event"
></blog-post>
<!-- OR -->
<blog-post
  ...
  v-on:enlarge-text="onEnlargeText"
></blog-post>

<!-- 在组件上使用 v-model -->
<custom-input v-model="searchText"></custom-input>
```

```js
// 使用事件抛出一个值
...
methods: {
  onEnlargeText: function (enlargeAmount) {
    this.postFontSize += enlargeAmount
  }
}

// 在组件上使用 v-model
Vue.component('custom-input', {
  props: ['value'],
  template: `
    <input
      v-bind:value="value"
      v-on:input="$emit('input', $event.target.value)"
    >
  `
})
```

> 动态组件|异步组件

- 在动态组件上使用 `<keep-alive>`
`<keep-alive>` 要求被切换到的组件都有自己的名字，不论是通过组件的 name 选项还是局部/全局注册。

```html
<!-- 根据 is 每次切换时 Vue 都创建了一个新的 currentTabComponent 实例 -->
<component v-bind:is="currentTabComponent"></component>

<!-- 失活的组件将会被缓存！-->
<keep-alive>
  <component v-bind:is="currentTabComponent"></component>
</keep-alive>
```

- [异步组件](https://cn.vuejs.org/v2/guide/components-dynamic-async.html#%E5%BC%82%E6%AD%A5%E7%BB%84%E4%BB%B6)
Vue 允许以一个工厂函数的方式定义组件，这个工厂函数会异步解析组件定义。Vue 只有在这个组件需要被渲染的时候才会触发该工厂函数，且会把结果缓存起来供未来重渲染。

```js
Vue.component('async-example', function (resolve, reject) {
    // 向 `resolve` 回调传递组件定义
    resolve({
      template: '<div>I am async!</div>'
    })
})
```

### 实例属性

- `data/vm.$data`

  Vue 实例的数据对象。Vue 将会递归将 `data` 的属性转换为 `getter/setter`，从而让 `data` 的属性能够响应数据变化。对象必须是纯粹的对象 (含有零个或多个的 `key/value` 对)。实例创建之后，可以通过 `vm.$data` 访问原始数据对象。Vue 实例也代理了 `data` 对象上所有的属性，因此访问 `vm.a` 等价于访问 `vm.$data.a`(以 `_` 或 `$` 开头的属性不会被代理)。

- `vm.$props`

  当前组件接收到的 `props` 对象。Vue 实例代理了对其 `props` 对象属性的访问。

- `vm.$el`

  Vue 实例使用的根 DOM 元素

- `vm.$options`

  用于当前 Vue 实例的初始化选项，一般在选项中包含自定义属性时使用。

  ```js
  new Vue({
    customOption: 'foo',
    created: function () {
      console.log(this.$options.customOption) // => 'foo'
    }
  })
  ```

- `vm.$parent`

  当前实例的父实例。

- `vm.$root`

  当前组件树的**根 Vue 实例**。如果当前实例没有父实例，此实例将会是其自己。

- `vm.$children`

  Vue 实例数组 `Array<Vue instance>`，当前实例的直接子组件(非响应且无法保证顺序)。

- `vm.$slots`

  只读，类型：`{ [name: string]: ?Array<VNode> }`。
  
  用来访问被插槽分发的内容。每个具名插槽有其相应的属性 (例如：`slot="foo"` 中的内容将会在 `vm.$slots.foo` 中被找到)。`default` 属性包括了所有没有被包含在具名插槽中的节点。一般在[渲染函数](https://cn.vuejs.org/v2/guide/render-function.html)书写一个组件时使用。

  ```js
  Vue.component('blog-post', {
    render: function (createElement) {
      var header = this.$slots.header
      var body   = this.$slots.default
      var footer = this.$slots.footer
      return createElement('div', [
        createElement('header', header),
        createElement('main', body),
        createElement('footer', footer)
      ])
    }
  })
  ```

- `vm.$scopedSlots`
  
  只读，类型 `{ [name: string]: props => Array<VNode> | undefined }`
  
  用来访问[作用域插槽](https://cn.vuejs.org/v2/guide/components-slots.html#%E4%BD%9C%E7%94%A8%E5%9F%9F%E6%8F%92%E6%A7%BD)。对于包括 `默认 slot` 在内的每一个插槽，该对象都包含一个返回相应 VNode 的函数。一般在[渲染函数](https://cn.vuejs.org/v2/guide/render-function.html)书写一个组件时使用。

  Vue2.6.0+，所有的 `$slots` 现在都会作为函数暴露在 `$scopedSlots` 中。如果你在使用渲染函数，不论当前插槽是否带有作用域，我们都推荐始终通过 `$scopedSlots` 访问它们。

- `vm.$refs`

  持有注册过 `ref` 特性 的所有 DOM 元素和组件实例(如果在普通的 DOM 元素上使用，引用指向的就是 DOM 元素；如果用在子组件上，引用就指向组件实例)。`$refs` 只会在组件渲染完成之后生效且不是响应式的。常用于在 JavaScript 里直接访问一个子组件。

  当 `ref` 和 `v-for` 一起使用的时候，`vm.$refs` 将会是一个包含了对应数据源的这些子组件的数组。

  ```html
  <!-- `vm.$refs.p` will be the DOM node -->
  <p ref="p">hello</p>

  <!-- `vm.$refs.child` will be the child component instance -->
  <child-component ref="child"></child-component>
  ```

  ```js
  // <input ref="input">
  methods: {
    // 用来从父级组件聚焦输入框
    focus: function () {
      this.$refs.input.focus()
    }
  }
  ```

- `vm.$isServer`

  当前 Vue 实例是否运行于服务器。

- `vm.$attrs`

  包含了父作用域中不作为 `prop` 被识别 (且获取) 的特性绑定 (`class` 和 `style` 除外)。当一个组件没有声明任何 `prop` 时，这里会包含所有父作用域的绑定 (`class` 和 `style` 除外)，并且可以通过 `v-bind="$attrs"` 传入内部组件——在创建高级别的组件时非常有用。

- `vm.$listeners`

  包含了父作用域中的 (不含 `.native` 修饰器的) `v-on` 事件监听器。它可以通过 `v-on="$listeners"` 传入内部组件——在创建更高层次的组件时非常有用。

### 实例方法

#### [数据](https://cn.vuejs.org/v2/api/#%E5%AE%9E%E4%BE%8B%E6%96%B9%E6%B3%95-%E6%95%B0%E6%8D%AE)

- `vm.$watch`：语法 `vm.$watch( expOrFn, callback, [options] )`
  - `{string | Function} expOrFn`
  - `{Function | Object} callback`
  - `{Object} [options]`
    - `{boolean} deep` 为了发现对象内部值的变化，可以在选项参数中指定 `deep: true`(监听数组的变动不需要)
    - `{boolean} immediate` 在选项参数中指定 `immediate: true` 将立即以表达式的当前值触发回调

  观察 Vue 实例变化的一个表达式或计算属性函数。回调函数得到的参数为新值和旧值(在变异 (不是替换) 对象或数组时，旧值将与新值相同，因为它们的引用指向同一个对象/数组。Vue 不会保留变异之前值的副本。)。表达式只接受监督的**键路径**。对于更复杂的表达式，用一个函数取代。`vm.$watch` 返回一个取消观察函数，用来停止触发回调。

  ```js
  // 键路径
  vm.$watch('a.b.c', function (newVal, oldVal) {
    // 做点什么
  })

  // 函数
  var unwatch = vm.$watch(
    function () {
      // 表达式 `this.a + this.b` 每次得出一个不同的结果时
      // 处理函数都会被调用。
      // 这就像监听一个未被定义的计算属性
      return this.a + this.b
    },
    function (newVal, oldVal) {
      // 做点什么
    }
  );

  // vm.$watch 返回一个取消观察函数，用来停止触发回调
  unwatch();
  ```

- `vm.$set`：语法 `vm.$set( target, key, value )`
  - `{Object | Array} target`
  - `{string | number} key`
  - `{any} value`

  全局 `Vue.set` 的别名，向响应式对象中添加一个属性，并确保这个新属性同样是响应式的，且触发视图更新。对象不能是 Vue 实例，或者 Vue 实例的根数据对象。

- `vm.$delete`：语法 `vm.$delete( target, key )`
  - `{Object | Array} target`
  - `{string | number} key`

  全局 `Vue.delete` 的别名。删除对象的属性。如果对象是响应式的，确保删除能触发更新视图。这个方法主要用于避开 Vue 不能检测到属性被删除的限制。目标对象不能是一个 Vue 实例或 Vue 实例的根数据对象。

#### [事件](https://cn.vuejs.org/v2/api/#%E5%AE%9E%E4%BE%8B%E6%96%B9%E6%B3%95-%E4%BA%8B%E4%BB%B6)

- `vm.$on`：语法 `vm.$on( event, callback )`
  - `{string | Array<string>} event` (数组只在 2.2.0+ 中支持)
  - `{Function} callback`

  监听当前实例上的自定义事件。事件可以由 `vm.$emit` 触发。回调函数会接收所有传入事件触发函数的额外参数。

  ```js
  vm.$on('test', function (msg) {
    console.log(msg)
  })
  vm.$emit('test', 'hi')
  // => "hi"
  ```

- `vm.$once`：语法 `vm.$once( event, callback )`
  - `{string} event`
  - `{Function} callback`

  监听一个自定义事件，但是只触发一次，在第一次触发之后移除监听器。

- `vm.$off`：语法 `vm.$off( [event, callback] )`
  - `{string | Array<string>} event` (只在 2.2.2+ 支持数组)
  - `{Function} [callback]`

  移除自定义事件监听器。如果没有提供参数，则移除所有的事件监听器；如果只提供了事件，则移除该事件所有的监听器；如果同时提供了事件与回调，则只移除这个回调的监听器。

- `vm.$emit`：语法 `vm.$emit( eventName, […args] )`

  触发当前实例上的事件。附加参数都会传给监听器回调。

#### 生命周期

- `vm.$mount`：语法 `vm.$mount( [elementOrSelector] )`

  如果 Vue 实例在实例化时没有收到 `el` 选项，则它处于“未挂载”状态，没有关联的 DOM 元素。可以使用 `vm.$mount()` 手动地挂载一个未挂载的实例。如果 `elementOrSelector` 参数缺失，模板将被渲染为文档之外的的元素，需要使用原生 DOM API 插入文档。方法返回实例 `vm` 自身。

  ```js
  var MyComponent = Vue.extend({
    template: '<div>Hello!</div>'
  })

  // 创建并挂载到 #app (会替换 #app)
  new MyComponent().$mount('#app')

  // 同上
  new MyComponent({ el: '#app' })

  // 或者，在文档之外渲染并且随后挂载
  var component = new MyComponent().$mount()
  document.getElementById('app').appendChild(component.$el)
  ```

- `vm.$forceUpdate()`

  迫使 Vue 实例重新渲染。注意它仅仅影响实例本身和插入插槽内容的子组件，而不是所有子组件。

- `vm.$nextTick( [callback] )`

  将回调延迟到下次 DOM 更新循环之后执行。在修改数据之后立即使用它，然后等待 DOM 更新。它跟全局方法 `Vue.nextTick` 一样，不同的是回调的 `this` 自动绑定到调用它的实例上。

  ```js
  new Vue({
    // ...
    methods: {
      // ...
      example: function () {
        // 修改数据
        this.message = 'changed'
        // DOM 还没有更新
        this.$nextTick(function () {
          // DOM 现在更新了
          // `this` 绑定到当前实例
          this.doSomethingElse()
        })
      }
    }
  })
  ```

- `vm.$destroy`

  完全销毁一个实例。清理它与其它实例的连接，解绑它的全部指令及事件监听器。触发 `beforeDestroy` 和 `destroyed` 的钩子。在大多数场景中你**不应该**调用这个方法。最好使用 `v-if` 和 `v-for` 指令以数据驱动的方式(修改涉及到的对象)控制子组件的生命周期。

### 计算属性缓存

**计算属性是基于它们的依赖进行缓存的。**只在相关依赖发生改变时它们才会重新求值。这就意味着下面代码中，只要 `message` 还没有发生改变，多次访问 `reversedMessage` 计算属性会立即返回之前的计算结果，而不必再次执行函数。(相比之下，每当触发重新渲染时，调用方法 `methods` 将总会再次执行函数。)

```js
var vm = new Vue({
  el: '#example',
  data: {
    message: 'Hello'
  },
  computed: {
    // 计算属性的 getter
    reversedMessage: function () {
      // `this` 指向 vm 实例
      return this.message.split('').reverse().join('')
    }
  }
})
```

计算属性默认只有 `getter` ，不过在需要时你也可以提供一个 `setter` ：

```js
// ...
computed: {
  fullName: {
    // getter
    get: function () {
      return this.firstName + ' ' + this.lastName
    },
    // setter
    set: function (newValue) {
      var names = newValue.split(' ')
      this.firstName = names[0]
      this.lastName = names[names.length - 1]
    }
  }
}
// ...
```

### 侦听器 `watch`

Vue 通过 `watch` 选项提供了一个方法来来响应数据的变化。当需要在数据变化时**执行异步**或**开销较大**的操作时，这个方式是最有用的。

```html
<div id="watch-example">
  <p>
    Ask a yes/no question:
    <input v-model="question">
  </p>
  <p>{{ answer }}</p>
</div>
<!-- 因为 AJAX 库和通用工具的生态已经相当丰富，Vue 核心代码没有重复 -->
<!-- 提供这些功能以保持精简。这也可以让你自由选择自己更熟悉的工具。 -->
<script src="https://cdn.jsdelivr.net/npm/axios@0.12.0/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/lodash@4.13.1/lodash.min.js"></script>
<script>
var watchExampleVM = new Vue({
  el: '#watch-example',
  data: {
    question: '',
    answer: 'I cannot give you an answer until you ask a question!'
  },
  watch: {
    // 如果 `question` 发生改变，这个函数就会运行
    question: function (newQuestion, oldQuestion) {
      this.answer = 'Waiting for you to stop typing...'
      this.debouncedGetAnswer()
    }
  },
  created: function () {
    // `_.debounce` 是一个通过 Lodash 限制操作频率的函数。
    // 在这个例子中，我们希望限制访问 yesno.wtf/api 的频率
    // AJAX 请求直到用户输入完毕才会发出。想要了解更多关于
    // `_.debounce` 函数 (及其近亲 `_.throttle`) 的知识，
    // 请参考：https://lodash.com/docs#debounce
    this.debouncedGetAnswer = _.debounce(this.getAnswer, 500)
  },
  methods: {
    getAnswer: function () {
      if (this.question.indexOf('?') === -1) {
        this.answer = 'Questions usually contain a question mark. ;-)'
        return
      }
      this.answer = 'Thinking...'
      var vm = this
      axios.get('https://yesno.wtf/api')
        .then(function (response) {
          vm.answer = _.capitalize(response.data.answer)
        })
        .catch(function (error) {
          vm.answer = 'Error! Could not reach the API. ' + error
        })
    }
  }
})
</script>
```

### 数组更新检测

- 变异方法

  Vue 包含一组观察数组的变异方法，调用以下数组方法将会触发视图更新
  `push()`, `pop()`, `shift()`, `unshift()`, `splice()`, `sort()`, `reverse()`

- 非变异方法

  调用数组的非变异方法返回一个新数组，不会改变原始数组。当使用非变异方法时，可以用新数组替换旧数组。

- 由于 JavaScript 的限制，Vue 不能检测到数组索引赋值（使用 `Vue.set()`/`vm.$set()` 解决）和修改 `length` 长度赋值(使用 `Array.prototype.splice()` 解决)的情况

```js
Vue.set(vm.items, indexOfItem, newValue)

vm.items.splice(indexOfItem, 1, newValue)
```

### 对象更新检测

Vue 可以检测对象属性的修改，但由于 JavaScript 的限制，不能检测对象属性的添加或删除(使用 `Vue.set(object, key, value)`/`vm.$set()` 或 `Object.assign` 解决)

```js
Vue.set(vm.userProfile, 'age', 27)

vm.userProfile = Object.assign({}, vm.userProfile, {
  age: 27,
  favoriteColor: 'Vue Green'
})
```

### 修饰符

- 事件修饰符，它们可串联使用：`.stop`、`.prevent`、`.capture`、`.self`、`.once`、`.passive`(尤其适合移动端)
`.passive` 同时和 `.prevent` 使用时，后者会被忽略
- 按键修饰符: `.enter`、`.tab`、`.delete`、`.esc`、`.space`、`.up`、`.down`、`.left`、`.right`
- 系统按键修饰符: `.ctrl`、`.alt`、`.shift`、`.meta(⌘|⊞|◆)`、`.exact` (允许精确控制系统修饰符组合键触发)
- 鼠标修饰符： `.left`、`.right`、`.middle`