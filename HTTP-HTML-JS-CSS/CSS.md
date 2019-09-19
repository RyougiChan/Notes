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

## https://www.cnblogs.com/mabelstyle/p/3715891.html
