# Unity Shader 入门

## 专业术语

### OpenGL/Directx

**图像应用编程接口**，这些接口用于渲染二维或三维图形。可以说，这些接口架起了上层应用程序和底层 GPU 的沟通桥梁。
![CPU、OpenGL/DirectX、显卡驱动和GPU之间的关系](http://static.zybuluo.com/candycat/4x54y4f2kjlhil8wq7oi1fpa/OpenGL%E5%92%8CDirectX.png)

### HLSL/GLSL/CG

着色语言(Shading Language)。

- HLSL: `High Level Shading Language`, DirectX
  由微软控制着色器的编译，就算使用了不同的硬件，同一个着色器的编译
结果也是一样的（前提是版本相同）。但支持 HLGL 的平台有限，几乎完全是微软自家的产品(Windows 、Xbox 360、PS3 等)。
- GLSL: `OpenGL Shading Language`, OpenGL
  GLSL 依赖硬件，而非操作系统层级。但这也意味着 GLSL 的编译结果将取决于硬件供应商，不同硬件供应商对 GLSL 的编译实现差异将导致编译结果的不一致。
- CG: `C for Graphic`, NVIDIA
  真正意义上的跨平台，它会根据平台的不同，编译成相应的中间语言。CG 语言的跨平台性很大原因取决于与微软的合作，这也导致 CG 语言的语法和 HLSL 非常相像，CG 语言可以无缝移植成 HLSL 代码。但缺点是可能无法完全发挥出 OpenGL 的最新特性。

### Draw Call

渲染命令。Draw Call 本身的含义很简单，就是 CPU 调用图像编程接口。

CPU 和 GPU 通过个**命令缓冲区(Command Buffer)**实现井行工作。命令缓冲区包含了一个命令队列，由 CPU 向其中添加命令，而由 GPU 从中读取命令，添加和读取的过程是互相独立的。

![命令缓冲区。CPU通过图像编程接口向命令缓冲区中添加命令，而GPU从中读取命令并执行。黄色方框内的命令就是 Draw Call，而红色方框内的命令用于改变渲染状态。我们使用红色方框来表示改变渲染状态的命令，是因为这些命令往往更加耗时](http://static.zybuluo.com/candycat/h9oh7t35lbjrgogxywarmu55/CommandBuffer.png)

**CPU 性能瓶颈**：GPU 的渲染能力是很强的，渲染 200 个还是 2000 个三角网格通常没有什么区别，因此渲染速度往往快于 CPU 提交命令的速度。如果 Draw Call 的数量太多，CPU就会把大量时间花费在提交 Draw Call 上，造成 CPU 的过载。

**优化**：

- 为了减少 Draw Call 的数量，可以采用**批处理(Batching)**的方法(把很多小的 Draw Call 合并成一个大的 Draw Call)。**批处理技术更加适合于那些静态的物体**(CPU 的内存中合并网格是个耗时操作，静态物体仅需合并一次)。
- 开发过程：避免使用大量很小的网格。当不可避免地需要使用很小的网格结构时，考虑是否可以**合并**它们。避免使用过多的材质。尽量在不同的网格之间**共用**同一个材质。

### 固定管线渲染

固定函数的流水线(Fixed-Function Pipeline), 也简称为固定管线，通常是指在较旧的 GPU 上实现的渲染流水线。这种流水线只给开发者提供一些配置操作。

## 渲染流水线

### 工作任务

> 渲染流水线的工作任务在于由一个三维场景出发、生成（或者说渲染）一张二维图像。换句话说，计算机需要从一系列的顶点数据、纹理等信息出发，把这些信息最终转换成一张人眼可以看到的图像。而这个工作通常是由 CPU 和 GPU 共同完成的。

### 最终目的

> 渲染流水线的最终目的在于生成或者说是渲染一张二维纹理，即我们在电脑屏幕上看到的所有效果。它的输入是一个虚拟摄像机、一些光源、 一些 Shader(Shader 仅仅是渲染流水线中的一个环节) 以及纹理等。

### 渲染流程(概念性阶段)

> 渲染流程分成 3 个阶段(概念性阶段)：应用阶段 (Application Stage)、几何阶段(Geometry Stage)、光栅化阶段(Rasterizer Stage)。每个阶段实际上又分为更小的阶段。

![渲染流程分成 3 个阶段(概念性阶段)](http://static.zybuluo.com/candycat/c0opg7bab4cwzyok5vek52hs/%E6%A6%82%E5%BF%B5%E6%B5%81%E6%B0%B4%E7%BA%BF.png)

#### 应用阶段

这个阶段是由我们的应用主导的，因此通常由 CPU 负责实现，开发者具有这个阶段的绝对控制权。这一阶段最重要的输出是渲染所需的几何信息，即**渲染图元** (rendering primitives)，将会被传递给下一个阶段 —— 几何阶段。

> 三个任务

- 准备好场景数据 (摄像机位置、模型、光源等)
- 粗粒度剔除 (culling) 工作 (剔除不可视物体)
- 设置每个模型的渲染状态 (材质、纹理、Shader 等)

> 三个阶段

- 把数据加载到显存中 (HDD [耗时操作]-> RAM [坐标、网格和纹理等]-> VRAM)
- 设置渲染状态 (这些状态定义了场景中的网格是怎样被涫染的)
![在同一状态下渲染3个网格](http://static.zybuluo.com/candycat/gld5mfj5o10kardzyn10p5a6/SetRenderState.png)
- 调用 Draw Call(渲染命令)，发起方是 CPU，接收方是 GPU(实际上就是 CPU 调用图像编程接口)。这个命令仅仅会指向一个需要被渲染的图元 (primitives) 列表，而不会再包含任何材质信息。
![CPU通过调用Draw Call来告诉GPU开始进行一个渲染过程。Draw Call会指向本次调用需要渲染的图元列表](http://static.zybuluo.com/candycat/5nuo5d8oh1c8sxexr3d7e935/DrawCall.png)

#### 几何阶段

几何阶段用于处理所有和要绘制的几何相关的事情 (绘制的图元、如何绘制、在何处绘制)，这一阶段通常在 GPU 上进行。几何阶段负责和每个渲染图元打交道，进行逐顶点、逐多边形的操作。这一阶段将会输出屏幕空间的二维顶点坐标、每个顶点对应的深度值、着色等相关信息，并传递给下一个阶段 —— 光栅化阶段。

> 主要任务：
把顶点坐标变换到屏幕空间中，再交给光栅器进行处理。

#### 光栅化阶段

使用几何阶段传递的数据(屏幕坐标系下的顶点位置以
及和它们相关的额外信息，如深度值【z坐标】、法线方向、视角方向等)来产生屏幕上的**像素**。对逐顶点数据（例如纹理坐标、顶点颜色等）进行插值，然后再进行逐像素处理，并渲染出最终的图像。

> 两个最重要的目标：
计算每个图元覆盖了哪些像素，以及为这些像素计算它们的颜色。

### GPU 流水线

GPU 渲染的过程就是 GPU 流水线。几何阶段和光栅化阶段可以分成若干更小的流水线阶段，这些流水线阶段由 GPU 来实现，每 个阶段 GPU 提供了不同的可配置性或可编程性。
![GPU的渲染流水线实现。颜色表示了不同阶段的可配置性或可编程性：绿色表示该流水线阶段是完全可编程控制的，黄色表示该流水线阶段可以配置但不是可编程的，蓝色表示该流水线阶段是由GPU固定实现的，开发者没有任何控制权。实线表示该shader必须由开发者编程实现，虚线表示该Shader是可选的](http://static.zybuluo.com/candycat/jundxsf604yuoy2zr3r1qkzp/GPU%E6%B5%81%E6%B0%B4%E7%BA%BF.png)

- 几何阶段
  - 顶点着色器(VertexShader)：
    *完全可编程*，它通常用于实现顶点的空间变换、顶点着色等功能。
  - 曲面细分着色器(Tessellation Shader)：
    一个可选的着色器，*完全可编程*，它用于细分图元。
    - 顶点着色器的处理单位是*顶点*，也就是说，输入进来的每个顶点都会调用一次顶点着色器。
    - 顶点着色器本身不可以创建或者销毁任何顶点，而且无法得到顶点与顶点之间的关系，即顶点之间相互独立 (GPU 可以利用本身的特性并行化处理每一个顶点，这意味着这一阶段的处理速度会很快)。
    - 主要工作：坐标变换和逐顶点光照
      - 坐标变换
        顶点着色器可以在这一步中改变顶点的位置，这在顶点动画中非常有用。**一个最基本的顶点着色器必须完成的一个工作是，把顶点坐标从模型空间转换到齐次裁剪空间。**
        ![顶点着色器会将模型顶点的位置变换到齐次裁剪坐标空间下，进行输出后再由硬件做透视除法得到NDC下的坐标](http://static.zybuluo.com/candycat/2zpu3oh7n6kpy4rosqtjugcy/Vertex%20Shader.png)
  - 几何着色器(Geometry Shader)：
    一个可选的着色器，*完全可编程*，它可以被用于执行逐图元(Per-Primitive) 的着色操作，或者被用于产生更多的图元。
  - 裁剪(Clipping)：
    这一阶段的目的是将那些不在摄像机视野内的顶点裁剪掉，并剔除某些三角图元的面片。这个阶段是*可配置*的(自定义一个裁剪操作)。
    一个图元和摄像机视野的关系有3种： 完全在视野内、部分在视野内、完全在视野外。完全在视野内的图元就继续传递给下一个流水线阶段， 完全在视野外的图元不会继续向下传递，因为它们不需要被渲染。而那些部分在视野内的图元需要进行一个处理，这就是裁剪。
    ![只有在单位立方体的图元才需要被继续处理。](http://static.zybuluo.com/candycat/08cvo0uahel9ygds4xkwrczp/Clipping.png)
  - 屏幕映射(Screen Mapping)：
    这一阶段是*不可配置和编程*的，它负责把每个图元的坐标转换到屏幕坐标系中。
    - 这一步输入的坐标仍然是三维坐标系下的坐标，屏幕映射的任务是把每个图元的 `x` 和 `y` 坐标转换到屏幕坐标系(Screen Coordinates) 下(屏幕映射不会对输入的 `z` 坐标做任何处理)。屏幕坐标系是一个二维坐标系，它和我们用于显示画面的分辨率有很大关系。
    ![屏幕映射将x、y坐标从（-1, 1）范围转换到屏幕坐标系中 ](http://static.zybuluo.com/candycat/7xtfj07anrw60g4y7cadkd8h/ScreenMapping.png)
    - OpenGL 和 DirectX 的屏幕坐标系差异
    ![OpenGL和DirectX的屏幕坐标系差异。对于一张512*512大小的图像，在OpenGL中其（0, 0）点在左下角，而在DirectX中其(0, 0)点在左上角 ](http://static.zybuluo.com/candycat/ul58wnwn76vj0gm20m3xsi9g/Screen%20Mapping_OpenGL_DirectX.png)
- 光栅化阶段
  - 三角形设置(Triangle Setup)：
    固定函数(Fixed-Function)的阶段，*不可配置和编程*。它的输出是为了给下一个阶段做准备。
    计算三角网格表示数据的过程。这个阶段会计算光栅化一个三角网格所需的信息。
  - 三角形遍历(Triangle Traversal)：
    固定函数(Fixed-Function)的阶段，*不可配置和编程*。这个阶段也可称为扫描变换(Scan Conversion)。这一步的输出就是得到一个**片元序列**。
    找到哪些像素被三角网格覆盖的过程。这个阶段检查每个像素是否被一个三角网格所覆盖。如果被覆盖的话，就会生成一个**片元(fragment)**(!一个片元并不是真正意义上的像素，而是包含了很多状态的集合【包括但不限于它的屏幕坐标、深度信息，以及其他从几何阶段输出的顶点信息，例如法线、纹理坐标等】，这些状态用于计算每个像素的最终颜色。)。
    ![三角形遍历的过程。根据几何阶段输出的顶点信息，最终得到该三角网格覆盖的像素位置。对应像素会生成一个片元，而片元中的状态是对三个顶点的信息进行插值得到的。](http://static.zybuluo.com/candycat/1ltkl388mkbbzbfgzm28f6gy/TriangleSetupAndTraversal.png)
  - 片元着色器(Fragment Shader)：
    *完全可编程*，它用于实现逐片元(Per-Fragment)的着色操作。
    - 片元着色器的**输入**是上一个阶段对顶点信息插值得到的结果，更具体来说，是根据那些从顶点着色器中输出的数据插值得到的。而它的**输出**是一个或者多个颜色值。
    - 这一阶段可以完成很多重要的渲染技术，其中最重要的技术之一就是**纹理采样**。为了在片元着色器中进行纹理采样，我们通常会在顶点着色器阶段输出每个顶点对应的纹理坐标，然后经过光栅化阶段对三角网格的3个顶点对应的纹理坐标进行插值后，就可以得到其覆盖的片元的纹理坐标。
    - 片元着色器的局限性：它仅可以影响单个片元，执行片元着色器时，无法把结果直接发给其他的片元(有一个情况例外，就是片元若色器可以访问到导数信息 gradient)。
    ![根据上一步插值后的片元信息，片元着色器计算该片元的输出颜色 ](http://static.zybuluo.com/candycat/lowfuoi0r43oxfgxkp9darur/FragmentShader.png)
  - OpenGL:逐片元操作(Per-Fragment Operations)/DirectX:输出合井阶段(Output-Merger)：
    负责执行很多重要的操作，例如修改颜色、深度缓冲、进行混合等，它是*不可编程*的，但具有*很高的可配置性*。
    ![逐片元操作阶段所做的操作。只有通过了所有的测试后，新生成的片元才能和颜色缓冲区中已经存在的像素颜色进行混合，最后再写入颜色缓冲区中](http://static.zybuluo.com/candycat/epejev04t6vudwsyo2el8rp0/Per-fragment%20Operations.png)
    这一阶段主要有两个任务：
    - 决定每个片元的可见性。这涉及了很多测试工作，例如两个最基本的测试：模板测试、深度测试。测试顺序并不是唯一的，而且虽然从逻辑上来说这些测试是在片元着色器之后进行的，但对于大多数 GPU 来说，它们会尽可能在执行片元着色器之前就进行这些测试以提高性能和效率。
      - **模板测试**：与之相关的是模板缓冲(Stencil Buffer)。实际上，模板缓冲和我们经常听到的颜色缓冲、深度缓冲几乎是一类东西。模板测试通常用于限制渲染的区域。另外，模板测试还有一些更高级的用法，如**渲染阴影、轮廓渲染**等。
      - **深度测试**：如果开启了深度测试，GPU会把该片元的深度值和已经存在于深度缓冲区中的深度值进行比较。这个比较函数也是可由开发者设置的。通常这个比较函数是小于等于的关系，即如果这个片元的深度值大于等于当前深度缓冲区中的值，那么就会舍弃它。这是因为我们总想只显示出离摄像机最近的物体，而那些被其他物体遮挡的就不需要出现在屏幕上。**透明效果**和深度测试以及深度写入的关系非常密切。
      **非常重要：**两个最基本的测试——深度测试和模板测试的实现过程
      ![模板测试和深度测试的简化流程图](http://static.zybuluo.com/candycat/28t2ora2kenj1uudwfgfig95/Stencil%20Test_Depth%20Test.png)
    - 如果一个片元通过了所有的测试，就需要把这个片元的颜色值和已经存储在颜色缓冲区中的颜色进行合并，或者说是**混合**。对于不透明物体，开发者可以关闭混合(Blend)操作。这样片元着色器计算得到的颜色值就会直接*覆盖*掉颜色缓冲区中的像素值。但对于半透明物体，我们就需要使用混合操作来让这个物体看起来是透明的。
    ![混合操作的简化流程图](http://static.zybuluo.com/candycat/k7q79qcgoqkw8myu1lpuy7he/Blending.png)

## Unity Shader 基础

在 Unity 中我们需要配合使用材质 (Material) 和 UnityShader 才能达到需要的效果。Unity Shader 定义了渲染所需的各种代码（如顶点着色器和片元着色器）、属性（如
使用哪些纹理等）和指令（渲染和标签设置等），而材质则允许我们调节这些属性，并将其最终赋给相应的模型。一个最常见的流程是：

- 创建一个材质
- 创建一个 UnityShader, 并把它赋给上一步中创建的材质
- 把材质赋给要渲染的对象
- 在材质面板中调整 UnityShader 的属性，以得到满意的效果。

### Unity Shader 类型

- Standard Surface Shader: 包含标准光照模型的表面着色器
- Unlit Shader: 不包含光照(但包含雾效)的基本顶点/片元着色器
- Image Effect Shader: 为实现各种屏幕后处理效果提供基本模板
- Compute Shader: 产生一种特殊的 Shader 文件，旨在利用 GPU 的并行性来进行一些与常规渲染流水线无关的计算

### Unity Shader 的基础：Shadarlab

在 Unity 中，所有的 Unity Shader 都是使用 ShaderLab 来编写的。 ShaderLab 是 Unity 提供的编写 Unity Shader 的一种说明性语言。

### Unity Shader 的结构

结构代码参考 [Unity Docs](Unity_Docs.md#Shader入门其之一)

#### Properties 语义块

***Properties 语义块支持的属性类型***

|属性类型|默认值的定义语法|例子|
|-------|-------------|----|
| Int   | `number` | `_int ("Int", Int) = 2` |
| Float | `number` | `_Float ("Float", Float) = 1.5` |
| Range(min, max)| `number` | `_Range("Range", Range(0.0, 5.0)) = 3.0` |
| Color | `(number,number,number,number)`  | `_Color ("Color", Color)= (1,1,1,1)` |
| Vector| `(number,number,number,number)`  | `_Vector ("Vector", Vector)= (2, 3, 6, 1)` |
| 2D    | `"defaulttexture" {}`  | `_2D ("2D", 2D) = "" {}` |
| Cube  | `"defaulttexture" {}`  | `_Cube ("Cube", Cube)= "white" {}` |
| 3D    | `"defaulttexture" {}`  | `_3D (''3D", 3D) = "black" {}` |

#### SubShader 语义块

每一个 Shader 至少有一个或者可以有多个 SubShader，当 Unity 渲染 Shader 时，它将遍历所有 SubShader 并使用硬件支持的第一个着色器。如果都不支持的话，Unity 就会使用 `Fallback` 语义 指定的 Unity Shader。

SubShader 中定义了一系列 Pass 以及可选的状态([RenderSetup])和标签([Tags])设置。

- Pass

每个 Pass 定义了一次完整的渲染流程，但如果 Pass 的数目过多，往往会造成渲染性能的下降。因此，我们应尽量使用最小数目的 Pass。状态和标签同样可以在 Pass 声明 (如果我们在 SubShader 进行了这些设置，那么将会用于所有的 Pass)。

- `UsePass`: 复用其他 UnityShader 中的 Pass
- `GrabPass`: 该 Pass 负责抓取屏器并将结果存储在一张纹理中，以用于后续的 Pass 处理

```cs
Pass {
  /*
   * 在 Pass 中定义该 Pass 的名称，通过这个名称， 我们可以使用 ShaderLab 的 UsePass 命令来直接使用其他 Unity Shader 中的 Pass。如：
   * `UsePass "MyShader/MYPASSNAME"`
   * ！！！需要注意：由于 Unity 内部会把所有 Pass 的名称转换成大写字母的表示，因此，在使用 UsePass 命令时必须使用大写形式的名字。
   */
  [Name]
  /*
   * 设置标签，但它的标签不同于 SubShader 的标签。
   */
  [Tags]
  /*
   * 设置渲染状态，SubShader 的状态设置同样适用于 Pass
   */
  [RenderSetup]
  // Other code
  // Pass 中可以使用固定管线的着色器命令。
}
```

- [RenderSetup]

设置显卡的各种状态

***ShaderLab 中常见的渲染状态设置选项***

|状态名称|设置指令|解释|
|-------|------|----|
| Cull  | Cull Back / Front / Off | 设置剔除模式：剔除背面/正面/关闭剔除|
| ZTest | ZTest Less Greater / LEqual / GEqual / Equal / NotEqual / Always | 设咒深度测试时使用的函数 |
| Zwrite| ZWrite On / Off  | 开启／关闭深度写入 |
| Blend | Blend SrcFactor DstFactor | 开启并设置混合模式 |

- [Tags]

SubShader 的标签(`Tags`)是一个键值对 (Key/Value Pair), 它的键和值都是字符串类型。这些键值对是 SubShader 和渲染引擎之间的沟通桥梁。它们用来告诉 Unity 的渲染引擎：SubShader 我希望怎样以及何时渲染这个对象。

语法：`Tags { "TagName1" = "Value1" "TagName2" = "Value2" }`

***SubShader 的标签块支待的标签类型(不能用于 Pass)***

| 标签类型  | 说明 | 例子 |
| -------  | --- | ---  |
| Queue    | 控制渲染顺序，指定该物体属于哪一个渲染队列，通过这种方式可以保证所有的透明物体可以在所有不透明物体后而被渲染，我们也可以自定义使用的渲染队列来控制物体的渲染顺序 | `Tags { "Queue" = "Transparent" }` |
| RenderType | 对着色器进行分类，例如这是一个不透明的着色器，或是一个透明的着色器等。这可以被用于着色器替换(Shader Replacement)功能 | `Tags { "RenderType" = "Opaque" }` |
| DisableBatching  | 一些 SubShader 在使用 Unity 的批处理功能时会出现问题， 例如使用了模型空间下的坐标进行顶点动画。这时可以通过该标签来直接指明是否对该SubShader 使用批处理 | `Tags { "DisableBatching" = "True"` |
| ForceNoShadowCasting  | 控制使用该 SubShader 的物体是否会投射阴影 | `Tags { "ForceNoShadowCasting" = "True" }` |
| lgnoreProjeclor | 如果该标签值为 `"True"`, 那么使用该 SubShader 的物体将不会受 Projector 的影响。通常用于半透明物体 | `Tags { "JgnoreProjector" = "True" }` |
| CanUseSpriteAtlas  | 当该 SubShader 是用于精灵(sprites)时，将该标签设为`"False"` | `Tags { "CanUseSpriteAtlas" = "False")` |
| PreviewType | 指明材质面板将如何预览该材质。默认情况下，材质将显示为一个球形，我们可以通过把该标签的值设为 "Plane" "SkyBox"来改变预览类型 | `Tags { "PreviewType" = "Plane")` |

***Pass 的标签块支待的标签类型***
| 标签类型  | 说明 | 例子 |
| -------  | --- | ---  |
| LightMode    | 定义该 Pass 在 Unity 的渲染流水线中的角色 | `Tags { "LightMode" = "ForwardBase" }` |
| RequireOptions    | 指定当满足某些条件时才渲染该 Pass, 它的值是一个由空格分隔的字符串。目前，Unity5 支持的选项有：Soft Vegetation。在后面的版本中， 可能会增加更多的选项 | `Tags { "RequireOptions" = "Soft Vegetation" }` |

#### Fallback

它指示程序在当前 Shader 中没有可以在用户的​​图形硬件上运行的 SubShaders 时应该使用哪个 Shader 来替代

```cs
Fallback "name"
// or
Fallback Off
```