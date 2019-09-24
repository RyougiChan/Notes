# CSS

## CSS 选择器

- `*` 通配符选择器
- `#` ID 选择器
- `.` 类选择器
- `X` 元素选择器
- `X + Y` 直接兄弟选择器，在 `X` 之后第一个兄弟节点中选择满足 `Y` 选择器的元素
- `X > Y` 子选择器
- `X Y` 后代选择器
- `X ~ Y` 兄弟选择器，选择 `X` 之后所有兄弟节点中满足 `Y` 选择器的元素
- `[attr]` 属性选择器，选择设置了 `attr` 属性的所有元素
- `[attr=value]` 属性选择器，选择设置了 `attr` 属性值为 `value` 的元素
- `[attr^=value]` 属性选择器，选择设置了 `attr` 属性值为以 `value` 开头的元素
- `[attr|=value]` 属性选择器，选择设置了 `attr` 属性值为 `value` 的元素或以 `value` 开头的元素
- `[attr$=value]` 属性选择器，选择设置了 `attr` 属性值为以 `value` 结尾的元素
- `[attr~=value]` 属性选择器，选择设置了 `attr` 属性值为以空字符分隔且第一个分隔元素为 `value` 的元素
- `[attr=value]*` 选择属性值中包含 `value` 的元素
- `X:link` 伪类选择器，鼠标点击之前，也称为原始状态
- `X:visited` 伪类选择器，鼠标点击之后状态
- `X:hover` 伪类选择器，鼠标悬停状态
- `X:active` 伪类选择器，鼠标点击之时的状态
- `X:focus` 伪类选择器，选择获得焦点的元素
- `X:first-child` 伪类选择器，选择 `X` 选择的第一个元素，且该元素是其父元素的第一个子元素
- `X:last-child` 伪类选择器，选择 `X` 选择的最后一个元素，且该元素是其父元素的最后一个子元素
- `X:only-child` 伪类选择器，选择 `X` 选择的元素，且该元素是其父元素的唯一子元素
- `X:first-of-type` 伪类选择器，选择 `X` 选择的元素，解析得到**元素标签**，选择此类型元素的第一个兄弟
- `X:last-of-type` 伪类选择器，选择 `X` 选择的元素，解析得到**元素标签**，选择此类型元素的最后一个兄弟
- `X:only-of-type` 伪类选择器，解析得到元素标签，选择 `X` 选择的元素，且该元素没有相同类型的兄弟节点
- `X:nth-child(an + b)` 伪类选择器，选择前面有 `an + b - 1` 个兄弟节点的元素(`n >= 0`)
- `X:nth-last-child(an + b)` 伪类选择器，选择后面面有 `an + b - 1` 个兄弟节点的元素(`n >= 0`)
- `X:nth-of-type(an+b)` 伪类选择器，解析得到**元素标签**，选择前面有 `an + b - 1` 个相同标签兄弟节点的元素
- `X:nth-last-of-type(an+b)` 伪类选择器，解析得到**元素标签**，选择后面有 `an + b - 1` 个相同标签兄弟节点的元素
- `:not(selector)` 伪类选择器，选择不符合 `selector` 的元素(不参与计算优先级)
- `::first-letter` 伪元素，选择块元素第一行的第一个字母
- `::first-line` 伪元素，选择块元素的第一行
- `X:after, X::after` `after` 伪元素，选择元素虚拟子元素（元素的最后一个子元素），CSS3中 `::` 表示伪元素

## display:none 和 visibility:hidden 比较

1. `display:none` 会把节点从文档渲染树中移除，不占据空间
   `visibility:hidden` 不会将节点移出渲染树，依旧会占据空间
2. `display:none` 不是继承属性，父元素设置 `display:none` 后无论如何子元素也会从渲染树中消失；
   `visibility:hidden` 是继承属性，父元素设置 `visibility:hidden` 后子元素设置 `visibility:visible` 后子元素可视
3. **`display:none` 会造成文档重排，而 `visibility:hidden` 只会使设置的元素重绘**
4. 读屏器会读取设置 `visibility:visible` 元素的内容，不会读取设置 `display:none` 元素的内容

## CSS 样式文件的引入方式 link/@import

区别项 | `<link>` | `@import`
----- | -------- | ---------
从属关系 | HTML 提供的标签，不仅可以加载 CSS 文件，还可以定义 RSS、rel 连接属性等 | CSS 提供的语法规则，只有导入样式表的作用
加载顺序 | 加载页面时，`<link>` 标签引入的 CSS 被**同时加载**，且最大限度支持并行下载 | `@import` 引入的 CSS 将在页面**加载完毕后**被加载，`@import` 过多嵌套导致串行下载，出现 `FOUC(Flash Of Unstyled Content )`
兼容性   | `<link>` 标签作为 HTML 元素，不存在兼容性问题 | **CSS2.1** 引入，只可在 IE5+ 使用
DOM可控性 | 可以通过 JS 操作 DOM ，插入 `<link>` 标签来改变样式 | 无法使用 `@import` 的方式插入样式

> FOUC, Flash Of Unstyled Content: 加载一个网页时，首先会出现一些内容，但是样式并没有完全加载好过一段时间后样式才发生变换。导致的原因可能是在文档底部加载样式表(如使用 `@import` 加载样式表)，可以通过在 `<head>` 使用 `<link>` 标签加载样式表文件来避免。

## CSS 盒模型

![Box Model](https://mdn.mozillademos.org/files/8685/boxmodel-(3).png)

$$
nodewidth = contentwidth + paddingwidth + borderwidth + marginwidth
$$

$$
nodeheight = contentheight + paddingheight + borderheight + marginheight
$$

> 标准盒模型

$$element.width = contentwidth$$

$$element.height = contentheight$$

> IE 盒模型

$$element.width = contentwidth + paddingwidth + borderwidth$$

$$element.height = contentheight + paddingheight + borderheight$$

## 各种元素的 width height margin padding 特性

1. 块级元素
2. 行内替换元素
  `width`, `height`, `margin`, `padding` 都正常显示，遵循标准的盒模型
3. 行内非替换元素
    1. `width`, `height` 不起作用，高度 由 `line-height` 来控制。
    2. `padding` 左右起作用，上下不会影响行高，但是对于有背景色和内边距的行内非替换元素，背景可以向元素上下延伸，但是行高没有改变。
    3. `margin` 左右作用起作用，上下不起作用，原因在于：行内非替换元素的外边距不会改变一个元素的行高

## css 元素的分类

1. 替换元素和不可替换元素
    1. 替换元素：这些元素往往没有实际的内容(即是一个**空元素**)，由浏览器根据元素的标签和属性，来决定元素的具体显示内容。这些元素包括 `<img>`、`<input>`、`<textarea>`、`<select>`、`<object>`。
    2. 不可替换元素：(X)HTML 的大多数元素是不可替换元素，即其内容直接表现给用户端（例如浏览器）
2. 显示元素
    1. 块级元素：在视觉上被格式化为块的元素，最明显的特征就是它默认在**横向**充满其**父元素**的内容区域，而且在其左右两边没有其他元素，即块级元素默认是独占一行。通过 CSS 设定了浮动（`float`属性，可向左浮动或向右浮动）以及设定显示（`display`）属性为 `block` 或 `list-item` 的元素都是块级元素。
    2. 行内元素：行内元素不形成新内容块，即在其左右可以有其他元素。`display` 属性等于 `inline` 的元素都是行内元素。几乎所有的可替换元素都是行内元素(但可通过设置 `display` 来改变)，例如`<img>`、`<input>`等等。

## CSS 继承属性

1. 字体相关属性
    1. `font-family`
    2. `font-weight`
    3. `font-size`
    4. `font-style`
2. 文本相关属性
    1. `text-align`
    2. `text-indent`
    3. `text-transform`
    4. `word-spacing`
    5. `letter-spacing`
    6. `line-height`
    7. `color`
3. 元素可见性
    `visibility`
4. 列表样式
    `list-style`
5. 光标属性
    `cursor`

## IE6 常见 CSS bug 及解决方法

> `!important` 并不覆盖掉在同一条样式的后面的规则。

```css
  /*
  IE6 及以下浏览器div的文本颜色为 #000，!important并没有覆盖后面的规则；
  其它浏览器下div的文本颜色为#f00
  */
  div {color:#f00!important; color:#000;}

  /* 可使用以下代码解决问题 */
  div {color:#f00!important;}
  div {color:#000;}
```

> IE6 不支持 `min-height` 属性

可使用以下 hack 模拟

```css
div {
    min-height: 100px;
    height: auto !important;
    /* IE6下内容高度超过会自动扩展高度 */
    height: 100px;
}
```

> `<ol>` 内的 `<li>` 的序号全为 `1`，不递增。

为 `<li>`设置样式 `display: list-item;` 可解决问题。

> IE6 只支持 `<a>` 标签的 `:hover` 伪类

如有需求只能使用 `JS` 为元素监听 `mouseenter`，`mouseleave` 事件

> IE5-8 不支持 `opacity` 属性

```css
div {
  opacity: 0.4
  filter: alpha(opacity=60); /* for IE5-7 */
  -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=60)"; /* for IE 8*/
}
```

> IE6 在设置 `height` 小于 `font-size` 时高度值为 `font-size` 值、

为元素设置 `font-size: 0;`

> IE6 不支持 `PNG` 透明背景

在 IE6 下使用 `gif` 格式图片

> IE6-7 不支持 `display: inline-block`

设置 `inline` 并触发 `hasLayout`

```css
div {
  display: inline-block;
  *display: inline;
  *zoom: 1;
}
```

> IE6 下浮动元素在浮动方向上与父元素边界接触元素的外边距会加倍。

1. 使用 `padding` 替换 `margin` 控制间距
2. 对浮动元素设置 `display: inline;`（CSS 标准规定浮动元素设置 `display:inline` 会自动调整为 `block`）

> IE6 下为块级元素设置 `margin:0 auto;` 不能使元素居中

为父元素设置 `text-align: center;`

> IE6 下为父元素设置 `overflow: auto;`，为子元素设置 `position: relative;`，子元素高于父元素时会溢出。

1. 去掉子元素的 `position: relative;`
2. 为父元素设置 `position: relative;`

## BFC(block formatting context)块级格式化上下文

块格式化上下文(Block Formatting Context, **BFC**) 是 Web 页面的可视化 CSS 渲染的一部分，是**块级盒子 (Block-level box)** 的布局过程发生的区域，也是**浮动 (float) 元素**与其他元素交互的区域。

> **Formatting context** 是 W3C CSS2.1 规范中的一个概念。它是页面中的一块渲染区域，并且有一套渲染规则，它决定了其子元素将如何定位，以及和其他元素的关系和相互作用。最常见的 Formatting context 有 **Block fomatting context(BFC)** 和 **Inline formatting context(IFC)**。

- BFC 的特点
  1. 在 BFC 中，内部的 **块级盒子 (Block-level box)** 会在垂直方向上一个一个依次放置
  2. 在 BFC 中，**块级盒子 (Block-level box)** 间的距离由 `margin` 控制，且同一个 BFC 下两个块级盒子的 `margin` 会重叠(外边距塌陷)
  3. 在 BFC 中，每一个盒子的 _左外边缘(margin-left)_ 会触碰到容器的 _左内边缘(border-left)_ （对于从右到左的格式来说，则触碰到右边缘）
  4. BFC 不会与外部的浮动元素重叠
  5. 在 BFC 中，浮动元素也参与 BFC 的高度计算
  6. BFC 是页面上的一个隔离的独立容器，容器里面的子元素不会影响到外面的元素
- BFC 的作用
  1. 清除内部浮动影响
  2. 防止元素与浮动元素重叠，可以用来自适应两栏布局
  3. 防止外边距塌陷（不常用，布局的时候两个盒子间只设置一个垂直方向的 `margin` 就可解决）
- BFC 的创建
  1. 根元素
  2. 浮动元素（`float` 属性值不为 `none`）
  3. 绝对定位（`position: absolute`）元素和固定定位（`position: fixed`）元素
  4. `overflow` 不为 `visibile` 的元素
  5. `display` 为 `inline-block, table-cell, table-caption, flex, inline-flex` 的元素

## display,float,position 的作用顺序

1. 元素设置 `display:none;`，`float`, `position` 将不起作用，且不产生框
2. 元素 `display` 值不为 `none`，如设置 `position:absolute;` 或 `position:fixed;`，框为绝对定位，此时 `float` 的计算属性(computed property) 值为 `none`。**display 根据下面的表格进行调整**。
3. 元素 `position` 计算属性值不为 `absolute` 或 `fixed`，`float` 值不为 `none`，框浮动。**display 根据下面的表格进行调整**。
4. 如果元素是根元素，**display 根据下面的表格进行调整**。
5. 剩余情况下 `display` 的值为指定值

指定值 | 计算值
----- | -----
`inline-table` | `table`
`inline`,`table-row-group`,`table-column`,`table-column-group`,`table-header-group`,`table-footer-group`,`table-row`,`table-cell`,`table-caption`,`inline-block` | `block`
`others` | (同指定值)
