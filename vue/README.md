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

