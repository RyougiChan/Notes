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

### 常用指令

- [Vue 常用指令](https://cn.vuejs.org/v2/api/#%E6%8C%87%E4%BB%A4)
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

  - `v-show` 根据表达式之真假值，切换元素的 display CSS 属性。[条件渲染(伪物) v-show](https://cn.vuejs.org/v2/guide/conditional.html#v-show)

  v-show 不支持 `<template>` 元素，也不支持 `v-else`

  ```html
  <h1 v-show="ok">Hello!</h1>
  ```

  - `v-if`, `v-else-if`(Vue2.1.0+), `v-else` 根据表达式的值的真假条件渲染元素。在切换时元素及它的数据绑定/组件被销毁并重建。如果元素是 `<template>` ，将提出它的内容作为条件块。[条件渲染](https://cn.vuejs.org/v2/guide/conditional.html)

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

  - `v-for` 基于源数据多次渲染元素或模板块。此指令之值，必须使用特定语法 `alias in expression` ，为当前遍历的元素提供别名

  从 2.6 起，`v-for` 也可以在实现了可迭代协议的值上使用，包括原生的 `Map` 和 `Set`。不过应该注意的是 Vue 2.x 目前并不支持可响应的 `Map` 和 `Set` 值，所以无法自动探测变更。

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

  - `v-on` 缩写 `@` 绑定事件 **监听器**。事件类型由参数指定。表达式可以是一个方法的名字或一个内联语句，如果没有修饰符也可以省略。用在普通元素上时，只能监听原生 DOM 事件。用在自定义元素组件上时，也可以监听子组件触发的自定义事件。
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

### vue 自定义组件

> 组件声明格式：组件名大小写使用 `kebab-case` 或 `PascalCase`。每个组件必须只有一个根元素，否则 Vue 会显示错误 `every component must have a single root element`

```js
// 全局注册
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
所有的 prop 都使得其父子 prop 之间形成了一个单向下行绑定：父级 prop 的更新会向下流动到子组件中，但是反过来则不行。每次父级组件发生更新时，子组件中所有的 prop 都将会刷新为最新的值。这意味着 **不应该** 在一个子组件内部改变 prop。以下是两种常见的试图改变一个 prop 的情形：
  - 这个 prop 用来传递一个初始值；这个子组件接下来希望将其作为一个本地的 prop 数据来使用。

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

- 监听子组件事件

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