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
- `[attr~=value]` 属性选择器，选择设置了 `attr` 属性值为以空字符分隔包含分隔元素为 `value` 的元素
- `[attr*=value]` 选择属性值中包含 `value` 的元素
- `X:link` 伪类选择器，鼠标点击之前，也称为原始状态
- `X:visited` 伪类选择器，鼠标点击之后状态，仅适用 `<a>` 标签
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

## CSS 样式文件的引入方式 link|@import

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

## 各种元素的 width|height|margin|padding 特性

1. 块级元素
2. 行内替换元素
  `width`, `height`, `margin`, `padding` 都正常显示，遵循标准的盒模型
3. 行内非替换元素
    1. `width`, `height` 不起作用，高度由 `line-height` 来控制。
    2. `padding` 左右起作用，上下不会影响行高，但是对于有背景色和内边距的行内非替换元素，背景可以向元素上下延伸，但是行高没有改变。
    3. `margin` 左右作用起作用，上下不起作用，原因在于：行内非替换元素的外边距不会改变一个元素的行高

## CSS 元素的分类

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
  /* 当内联元素的 hasLayout 为 true 的时候，可以给这个内联元素设定高度和宽度并得到期望的效果 */
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
  2. 在 BFC 中，**块级盒子 (Block-level box)** 间的距离由 `margin` 控制，且同一个 BFC 下两个块级盒子垂直方向上的 `margin` 会重叠(外边距塌陷)
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

## display|float|position 的作用顺序

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

## 清除浮动(clearfix)的方法

1. 在容器闭合标签之前添加一个设置CSS `clear:both` 属性的元素(出现冗余元素)。
2. 父元素触发 **[块级格式化上下文(BFC)](#BFC(block%20formatting%20context)块级格式化上下文)** 可清除内部浮动的影响。
3. 设置容器元素伪元素(推荐方法[SEE ALSO](http://nicolasgallagher.com/micro-clearfix-hack/))，已知支持 `Firefox 3.5+, Safari 4+, Chrome, Opera 9+, IE 6+`。

```css
/**
 * 在标准浏览器下
 * 1 content 内容为空格用于修复 opera 下文档中出现
 *   contenteditable 属性时在清理浮动元素上下的空白
 * 2 使用 display 使用 table 而不是 block：可以防止容器和
 *   子元素 top-margin 折叠，这样能使清理效果与 BFC，IE6/7
 *   zoom: 1;一致
 */
.cf:before,
.cf:after {
    content: " "; /* 1 */
    display: table; /* 2 */
}

.cf:after {
    clear: both;
}

/**
 * IE 6/7 下使用
 * 通过触发 hasLayout 实现包含浮动
 */
.cf {
    *zoom: 1;
}
```

## 包含块(Containing Block)

ref: [https://developer.mozilla.org/en-US/docs/Web/CSS/Containing_block](https://developer.mozilla.org/en-US/docs/Web/CSS/Containing_block)

### 确定包含块

确定一个元素的包含块的过程完全依赖于这个元素的 `position` 属性

`position` | Containing Block
---------- | ----------------
`static`,`relative` | 由它的最近的祖先块元素（比如说`inline-block`, `block` 或 `list-item`元素）或格式化上下文(比如说 `table`, `flex`, `grid`, `block` 容器自身)的内容区的边缘组成
`absolute` | 由它的最近的 `position` 的值不是 `static` （也就是值为 `fixed`, `absolute`, `relative` 或 `sticky`）的祖先元素的内边距区的边缘组成
`fixed`    | 在连续媒体的情况下(continuous media)包含块是 `viewport` ,在分页媒体(paged media)下的情况下包含块是**分页区域**(page area)

如果 `position` 是 `absolute` 或 `fixed`，它的包含块也可能是由满足以下条件的最近祖先元素的 `padding` 块的边缘组成。

1. `transform` 或 `perspective` 属性值不是 `none`
2. `will-change` 属性值为 `transform` 或 `perspective`
3. `filter` 属性值不为 `none` 或 `will-change` 属性值为 `filter`(仅适用于Firefox)
4. `contain` 属性值为 `paint`(`contain: paint;`)

### 根据包含块计算百分值

1. `height`, `top` 及 `bottom` 的百分值通过包含块的 `height` 的值计算。如果包含块的 `height` 值会根据它的内容变化，而且包含块的 `position` 属性的值被赋予 `relative` 或 `static` ，那么这些值的计算值为 `0`。
2. `width`, `left`, `right`, `padding`, `margin` 这些属性值由包含块的 `width` 属性的值来计算。

## 堆叠上下文(The stacking context)

Ref: [https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index/The_stacking_context](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index/The_stacking_context)

在满足以下条件的情况下，堆叠上下文由文档中的任何元素在文档中的任何位置形成：

1. 文档根元素 `<html>`
2. 元素的 `position` 属性值为 `absolute` 或 `relative` 并且 `z-index` 的属性值不为 `auto`
3. 元素的 `position` 属性值为 `fixed` 或 `sticky`(`sticky` 适用于所有移动版浏览器)
4. 元素是 **flex 容器(flexbox)** 的子元素并且 `z-index` 的属性值不为 `auto`
5. 元素是 **网格容器(grid container)** 的子元素并且 `z-index` 的属性值不为 `auto`
6. 元素的 `opacity` 属性值小于 `1`
7. 元素的 `mix-blend-mode` 属性值不为 `normal`
8. 元素具有以下任意一个属性，属性值不为 `none`
    1. `transform`
    2. `filter`
    3. `perspective`
    4. `clip-path`
    5. `mask / mask-image / mask-border`
9. 元素设置了 CSS 属性 `isolation: isolate;`
10. 元素设置了 CSS 属性 `-webkit-overflow-scrolling: touch;`
11. 元素的 `will-change` 属性值设置为在非初始值上创建堆栈上下文的**属性**
12. 元素设置了 CSS 属性 `contain`，且其值为 `layout`, `paint` 或包含其中任何一个的复合值(如：`contain: strict, contain: content`)

## 水平居中元素

1. 水平居中常规流中 `inline` 的元素：
    为父元素设置 `text-align:center`
2. 水平居中常规流中 `block` 的元素：
    设置元素宽度 `width`，设置 `margin` 属性 `margin: 0 auto;`(IE6 需要先为父元素设置 `text-align: center`，再为元素本身修改为需要的值)
3. 水平居中浮动元素(设置了 `float` 且不为 `none`)：
    设置元素宽度 `width`，设置 `position:relative;`，设置左(右)偏移量 `left:50%;`，设置左外边距为宽度的一半乘以 `-1`

    ```css
    div {
        width: 100px;
        height: 100px;
        background-color: aquamarine;
        float: left;
        position: relative;
        left: 50%;
        margin-left: -50px;
    }
    ```

4. 水平居中绝对定位元素
    1. 设置元素宽度 `width`，设置左(右)偏移量 `left:50%;`，设置左边距为宽度的一半乘以 `-1`

        ```css
        div {
            width: 100px;
            height: 100px;
            background-color: aquamarine;
            position: absolute;
            left: 50%;
            margin-left: -50px;
        }
        ```

    2. 设置元素宽度 `width`，设置左右偏移量为 0 `left:0; right:0;`，设置左右外边距为 auto `margin:0 auto`

        ```css
        div {
            width: 100px;
            height: 100px;
            background-color:blueviolet;
            position: absolute;
            left: 0;
            right: 0;
            margin: auto;
        }
        ```

## 垂直居中元素

1. 垂直居中绝对定位元素

    ```css
    div {
        width: 100px;
        height: 100px;
        background-color:blueviolet;
        overflow: auto; /* 建议设置，防止内容越界溢出 */
        position: absolute;
        /*
        设置 top: 0; left: 0; bottom: 0; right: 0;
        将给浏览器重新分配一个边界框，此时该块block将填充
        其父元素的所有可用空间
        */
        top: 0;
        bottom: 0;
        margin: auto; /* equals to margin-top:auto; margin-bottom:auto */
    }
    ```

2. 负外边距

    ```css
    div {
        width: 100px;
        height: 100px;
        position: absolute;
        top: 50%;
        margin-top: -50px;
    }
    ```

3. 使用 `transform`

    ```css
    div {
        position: absolute;
        top: 50%;
        -webkit-transform: translate(0,-50%);
        -ms-transform: translate(0,-50%);
        transform: translate(0,-50%);
    }
    ```

4. 利用表格单元格(`table-cell`)

    ```html
    <div class="Center-Container is-Table">
        <div class="Table-Cell">
            <div class="Center-Block">
            <!-- CONTENT -->
            </div>
        </div>
    </div>
    ```

    ```css
    .Center-Container.is-Table {
        display: table;
    }
    .is-Table .Table-Cell {
        display: table-cell;
        vertical-align: middle;
    }
    .is-Table .Center-Block {
        width: 50%;
        margin: 0 auto;
    }
    ```

5. 利用行内块元素(`inline-block`)

    ```html
    <div class="b" id="b6">
        <div class="inner"></div>
    </div>
    ```

    ```css
    #b6::after,
    #b6 > .inner {
        display: inline-block;
        vertical-align: middle;
    }
    #b6::after {
        content: ' ';
        height: 100%;
    }
    ```

6. 使用 CSS3 的 Flexbox

    ```css
    div {
        display: -webkit-flex;
        display: flex;
        align-items: center;
    }
    ```
