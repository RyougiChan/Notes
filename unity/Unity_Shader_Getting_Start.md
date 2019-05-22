# Unity Shader 入门

## 专业术语

### OpenGL/Directx

**图像应用编程接口**，这些接口用于渲染二维或三维图形。可以说，这些接口架起了上层应用程序和底层 GPU 的沟通桥梁。
![CPU、OpenGL/DirectX、显卡驱动和GPU之间的关系](http://static.zybuluo.com/candycat/4x54y4f2kjlhil8wq7oi1fpa/OpenGL%E5%92%8CDirectX.png)

### HLSL/GLSL/CG

着色语言(Shading Language)。

- HLSL: `High Level Shading Language`, DirectX
  由微软控制着色器的编译，就算使用了不同的硬件，同一个着色器的编译
结果也是一样的（前提是版本相同）。但支持 HLGL 的平台有限，几乎完全是微软自家的产品(Windows、Xbox 360 等)。
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
    一个图元和摄像机视野的关系有3种： 完全在视野内、部分在视野内、完全在视野外。完全在视野内的图元就继续传递给下一个流水线阶段，完全在视野外的图元不会继续向下传递，因为它们不需要被渲染。而那些部分在视野内的图元需要进行一个处理，这就是裁剪。
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

在 Unity 中，所有的 Unity Shader 都是使用 ShaderLab 来编写的。ShaderLab 是 Unity 提供的编写 Unity Shader 的一种说明性语言。

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
   * 在 Pass 中定义该 Pass 的名称，通过这个名称，我们可以使用 ShaderLab 的 UsePass 命令来直接使用其他 Unity Shader 中的 Pass。如：
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
| Zwrite| ZWrite On / Off  | 开启/关闭深度写入 |
| Blend | Blend SrcFactor DstFactor | 开启并设置混合模式 |

- [Tags]

SubShader 的标签(`Tags`)是一个键值对 (Key/Value Pair), 它的键和值都是字符串类型。这些键值对是 SubShader 和渲染引擎之间的沟通桥梁。它们用来告诉 Unity 的渲染引擎：SubShader 我希望怎样以及何时渲染这个对象。

语法：`Tags { "TagName1" = "Value1" "TagName2" = "Value2" }`

***SubShader 的标签块支待的标签类型(不能用于 Pass)***

| 标签类型  | 说明 | 例子 |
| -------  | --- | ---  |
| Queue    | 控制渲染顺序，指定该物体属于哪一个渲染队列，通过这种方式可以保证所有的透明物体可以在所有不透明物体后而被渲染，我们也可以自定义使用的渲染队列来控制物体的渲染顺序 | `Tags { "Queue" = "Transparent" }` |
| RenderType | 对着色器进行分类，例如这是一个不透明的着色器，或是一个透明的着色器等。这可以被用于着色器替换(Shader Replacement)功能 | `Tags { "RenderType" = "Opaque" }` |
| DisableBatching  | 一些 SubShader 在使用 Unity 的批处理功能时会出现问题，例如使用了模型空间下的坐标进行顶点动画。这时可以通过该标签来直接指明是否对该SubShader 使用批处理 | `Tags { "DisableBatching" = "True"` |
| ForceNoShadowCasting  | 控制使用该 SubShader 的物体是否会投射阴影 | `Tags { "ForceNoShadowCasting" = "True" }` |
| lgnoreProjeclor | 如果该标签值为 `"True"`, 那么使用该 SubShader 的物体将不会受 Projector 的影响。通常用于半透明物体 | `Tags { "JgnoreProjector" = "True" }` |
| CanUseSpriteAtlas  | 当该 SubShader 是用于精灵(sprites)时，将该标签设为`"False"` | `Tags { "CanUseSpriteAtlas" = "False")` |
| PreviewType | 指明材质面板将如何预览该材质。默认情况下，材质将显示为一个球形，我们可以通过把该标签的值设为 `"Plane"` `"SkyBox"`来改变预览类型 | `Tags { "PreviewType" = "Plane")` |

***Pass 的标签块支待的标签类型***
| 标签类型  | 说明 | 例子 |
| -------  | --- | ---  |
| LightMode    | 定义该 Pass 在 Unity 的渲染流水线中的角色 | `Tags { "LightMode" = "ForwardBase" }` |
| RequireOptions    | 指定当满足某些条件时才渲染该 Pass, 它的值是一个由空格分隔的字符串。目前，Unity5 支持的选项有：`Soft Vegetation`。在后面的版本中，可能会增加更多的选项 | `Tags { "RequireOptions" = "Soft Vegetation" }` |

#### Fallback

它指示程序在当前 Shader 中没有可以在用户的​​图形硬件上运行的 SubShader 时应该使用哪个 Shader 来替代，为每个 Unity Shader 正确设置 `Fallback` 是非常堂要的。

```cs
Fallback "name"
// or
Fallback Off
```

#### 其他语义(不常用)

- `CustomEditor` 自定义材质面板的编辑界面

```cs
Shader "example" {
    // properties and subshaders here...
    CustomEditor "MyCustomEditor"
}
```

- `Category` 对 UnityShader 中的命令进行分组

```cs
Shader "example" {
    Category {
        Fog { Mode Off }
        Blend One One
        SubShader {
            // ...
        }
        SubShader {
            // ...
        }
        // ...
    }
}
```

### Unity Shader 的形式

**在 Unity 里。Unity Shader 实际上指的是一个 ShaderLab 文件 —— 硬盘上以 `.shader` 为后缀的一种文件。**

#### 表面着色器 ([Surface Shader](https://docs.unity3d.com/Manual/SL-SurfaceShaders.html))

Unity 自己创造的一种着色器代码类型。它需要的代码量很少，Unity 在背后做了很多工作，但渲染的代价比较大。其本质还是**顶点/片元着色器**，它存在的价值在于，Unity 为我们处理了很多光照细节。

表面着色器被定义在 SubShader 语义块（而非 Pass 语义块）中的 `CGPROGRAM` 和 `ENDCG` 之间。原因是，表面着色器不需要开发者关心使用多少个 Pass、每个 Pass 如何渲染等问题，Unity 会在背后为我们做好这些事情。

***表面着色器简例***

```cs
Shader "Custom/Simple Surface Shader" {
  SubShader {
    Tags { "RebderType" = "Opaque" }
    CGPROGRAM
    #pragma surface surf Lambert
    struct Input {
      float4 color : COLOR;
    }
    void surf (Input IN, inout SUrfaceOutput o) {
      o.Albedo = 1;
    }
    ENDCG
  }
  Fallback "Diffuse"
}
```

#### 顶点/片元着色器([Vertex/Fragment Shader](https://docs.unity3d.com/Manual/SL-ShaderPrograms.html))

[Shader入门其之二](Unity_Docs.md#Shader入门其之二)

顶点/片元着色器是写在 Pass 语义块内，而非SubShader内的。原因是我们需要自已定义每个 Pass 需要使用的 Shader 代码。我们**可以控制渲染的实现细节**。

***顶点/片元着色器简例***

```cs
Shader "Custom/Simple VertexFragment Shader" {
  SubShader {
    Pass {
      CGPROGRAM

      #pragma vertex vert
      #pragma fragment frag

      float4 vert (float4 v : POSITION) : SV_POSITION {
        return mul(UNITY_MATRIX_MVP, v);
      }

      fixed4 frag () : SV_Target {
        return fixed4(1.0, 0.0, 0.0, 1.0);
      }

      ENDCG
    }
  }
}
```

#### 固定函数着色器

[Shader入门其之一](#Unity_Docs.md#Shader入门其之一)

对于不支持**可编程管线着色器**(表面|顶点/片元着色器)的设备，需要使用**固定函数着色器 (Fixed Function Shader)**来完成渲染。这些着色器往往只可以完成一些非常简单的效果。

固定函数着色器的代码被定义在 Pass 语义块中，需要完全使用 ShaderLab 的语法编写。由于现在绝大多数 GPU 都支待可编程的渲染管线，这种固定管线的编程方式已经逐渐被**抛弃**。实际上，在 Unity 5.2 中，所有固定函数着色器都会被 Unity 编译成对应的顶点/片元着色器。

***固定函数着色器***

```cs
Shader "Tutorial/Basic" {
  Properties {
    Color ("Main Color", Color) = (1, 0.5, 0.5, 1)
  }
  SubShader {
    Pass {
      Material {
        Diffuse [_Color]
      }
      Lighting On
    }
  }
}
```

## Shader 数学基础

### 笛卡尔坐标系

#### 二维笛卡尔坐标系

屏幕映射中，OpenGL 和 DirecX 使用不同的二维笛卡尔坐标系

![在屏幕映射时，OpenGL和DirectX使用了不同方向的二维笛卡尔坐标系](http://static.zybuluo.com/candycat/s4twn4lnbvlac7ci3mwwbe4d/2d_cartesian_opengl_directx.png)

#### 三维笛卡尔坐标系

- 左手坐标系 (left-handed coordinate space)
  正向旋转的定义：左手法则
- 右手坐标系 (right-handed coordinate space)
  正向旋转的定义：右手法则

#### Unity 使用的坐标系

- 模型空间和世界空间：左手坐标系

- 观察空间：右手坐标系
  观察空间，通俗来讲就是**以摄像机为原点**的坐标系。在这个坐标系中，摄像机的前向是z轴的负方向，这与在模型空间和世界空间中的定义相反。也就是说，z轴坐标的减少意味着场景深度的增加。
  ![在Unity中，观察空间使用的是右手坐标系，摄像机的前向是z轴的负方向，z轴越小，物体的深度越大，离摄像机越远](http://static.zybuluo.com/candycat/lrhkf34n8p5fz7mzyro7r72m/unity_camera_cartesian.png)

### 点和矢量

#### 矢量运算

- 矢量和标量的乘法/除法

  从儿何意义上看，把一个矢量 `v` 和一个标量 `k` 相乘，意味着对矢量 `v` 进行一个大小为 `|k|` 的缩放。
- 矢量的加法和减法
  
  可以对两个矢雇进行相加【三角形定则(triangle rule)】或相减，其结果是一个相同维度的新矢量。只需要把两个矢量的对应分量进行相加或相减即可。
  
  一个矢量不可以和一个标量相加或相减，或者是和不同维度的矢量进行运算。
- 矢量的模

  模可理解为矢量在空间中的长度
- 单位矢量

  单位矢量指的是那些**模为 1**的矢量。单位矢量也被称为被`归一化的矢量(normalizedvector)`。对任何给定的非零矢量，把它转换成单位矢量的过程就被称为`归一化(normalization)`。

  零矢量不可以被归一化。

- 矢量的点积(内积)

  矢量的点积一个很重要的几何意义是**投影(projection)**。

  - 公式一：
    `a·b = (ax, ay, az)·(bx, by, bz) = axbx + ayby + azbz`
    - 性质一：
      `(ka)·b = a·(kb) = k(a·b)`
    - 性质二：
      `a·(b+c) = a·b + a·c`
    - 性质三：
      `a·a = |a|^2`
  - 公式二：
    `a·b = |a||b|cosθ`
- 矢量的叉积(外积)

  对两个矢最进行叉积的结果会得到一个同时垂直于这两个矢量的新矢量。最常见的一个应用就是计算垂直于一个平面、三角形的矢量。另外，还可以用于判断三角面片的朝向。

  - 公式：
  `a x b = (ax, ay, az) x (bx, by, bz) = (aybz - azby, azbx - axbz, axby - aybx)`
  ![三维矢量叉积的计算规律](http://static.zybuluo.com/candycat/yrl5ol849v5h8892l4bqlgrh/vector_cross_diagram.png)

  - 模
  `|a x b| = |a||b|sinθ`

  - 方向
  由`a`转动到`b`时右手定则大拇指指向

### 矩阵

矢量可以看成是 `nx1` 的列矩阵 (column matrix) 或 `1xn` 的行矩阵 (row matrix),其中 n 对应了矢量的维度。

#### 矩阵运算

- 矩阵和标量的乘法

  矩阵和标量之间的乘法非常简单，就是矩阵的每个元素和该标量相乘。

  ```cs
             ⎡ m11 m12 m13 ⎤   ⎡ km11 km12 km13 ⎤
  kM = Mb = k⎢ m21 m22 m23 ⎥ = ⎢ km21 km22 km23 ⎥
             ⎣ m31 m32 m33 ⎦   ⎣ km31 km32 km33 ⎦
  ```

- 矩阵和矩阵的乘法

  一个 `rxn` 的矩阵 A 和一个 `nxc` 的矩阵 B 相乘，它们的结果 AB 将会是一个 `rxc` 大小的矩阵(第一个矩阵的列数必须和第二个矩阵的行数相同，否则两个矩阵不能相乘)。C 中的每一个元素 Cij 等于 A 的第 i 行所对应的矢量和 B 的第 j 列所对应的矢量进行矢量点乘的结果。
  ![计算c23的过程](http://static.zybuluo.com/candycat/u6urub3wacveq0qcr6112we5/matrix_mul.png)
  - 性质一：
    矩阵乘法不满足交换律。通常下，`AB != BA`。
  - 性质二：
    矩阵乘法满足结合律。`(AB)C = A(BC)`。

#### 特殊矩阵

- 方块矩阵

  方块矩阵(squarematrix)，简称方阵，是指那些行和列数目相等的矩阵。在三维渲染里，最常使用的就是 `3x3` 和 `4x4` 的方阵。
- 对角矩阵

  如果一个矩阵除了对角元素外的所有元素都为 0, 那么这个矩阵就叫做对角矩阵(diagonal matrix)。

  ```cs
  ⎡ 3 0 0 ⎤
  ⎢ 0 1 0 ⎥
  ⎣ 0 0 2 ⎦
  ```

- 单位矩阵

  一个特殊的对角矩阵，用`In`来表示。任何矩阵和单位矩阵相乘的结果还是原来的矩阵。`MI = IM = M`。其存在意义和标量中的数字 `1` 一样。

  ```cs
  ⎡ 1 0 0 ⎤
  ⎢ 0 1 0 ⎥
  ⎣ 0 0 1 ⎦
  ```

- 转置矩阵

  转置矩阵 (transposed matrix) 实际是对原矩阵的一种运算，即**转置运算**。给定一个 `rxc` 的 矩阵 `M`，它的转置可以表示成 `MT`，这是一个 `cxr` 的矩阵。
  - 性质一：矩阵转置的转置等于原矩阵。`(MT)T = M`
  - 性质二：矩阵串接的转置，等于反向串接各个矩阵的转置。`(AB)T = BTAT`

- 逆矩阵

  不是所有的矩阵都有逆矩阵，逆矩阵的第一个前提该矩阵必须是一个方阵。给定一个方阵`M`，它的逆矩阵用 `M-1` 来表示。逆矩阵最重要的性质就是，如果我们把`M`和 `M-1` 相乘得到的结果将会是一个单位矩阵。`MM-1 = M-1M = I`

  逆矩阵是具有几何意义的。矩阵表示一个变换，而逆矩阵允许我们还原这个变换。如果我们使用变换矩阵 `M` 对矢量 v 进行了一次变换，然后再使用它的逆矩阵 `M-1` 进行另一次变换，那么我们会得到原来的矢量 v。`M-1(Mv) = (M-1M)v = Iv = v`

  如果一个矩阵有对应的逆矩阵，我们就说这个矩阵是**可逆的(invertible)**或者说是**非奇异的(nonsingular)**；相反的，如果一个矩阵没有对应的逆矩阵，我们就说它是**不可逆的(noninvertible)**或者说是**奇异的(singular)**。如果一个矩阵的行列式 (determinant) 不为 0, 那么它就是可逆的。
  - 性质一：
    逆矩阵的逆矩阵是原矩阵本身。`(M-1)-1 = M`
  - 性质二：
    单位矩阵的逆矩阵是它本身。`(I)-1 = I`
  - 性质三：
    转置矩阵的逆矩阵是逆矩阵的转置。`(MT)-1 = (M-1)T`
  - 性质四：
    矩阵串接相乘后的逆矩阵等于反向串接各个矩阵的逆矩阵。`(ABC)-1 = (C-1)(B-1)(A-1)`

- 正交矩阵

  如果一个方阵 `M` 和它的转置矩阵的乘积是单位矩阵的话，我们就说这个矩阵是**正交的(orthogonal)**。反过来也是成立的。`MMT = MTM = I` 结合逆矩阵，`MT = M-1`

#### Unity 中的矩阵运算

在 Unity 中，常规做法是把矢量放在矩阵的右侧，即把矢量转换成**列矩阵**来进行运算。

#### 矩阵的几何意义：变换

变换(transform), 指的是我们把一些数据，如点、方向矢批甚至是颜色等，通过某种方式进行转换的过程。

- 线性变换(linear transform)

  可以保留矢量加 `f(x)+f(y)=f(x+y)` 和标量乘 `kf(x) =f(kx)` 的变换。

  图形学中的线性变换：
  - **缩放(scale)**，eg. `f(x)=2x`
  - **旋转(rotation)**，对于线性变换来说，如果我们要对一个三维的矢量进行变换，那么仅仅使用 `3x3` 的矩阵就可以表示所有的线性变换。
  - 错切(shear)
  - 镜像(mirroring/reflection)
  - 正交投影(orthographic projection)
- 平移变换
- 仿射变换(affine transform)

  合并线性变换和平移变换的变换类型。**仿射变换**可以使用一个 `4x4` 的矩阵来表示，为此，我们需要把矢量扩展到四维空间下，这就是**齐次坐标空间(homogeneous space)**。

***图形学中常见变换矩阵的名称和它们的特性***

| 变换名称 | 是否线性变换 | 是否仿射变换 | 是否逆矩阵 | 是否正交矩阵 |
|---------|------------|------------|----------|------------|
|平移矩阵|N|Y|Y|N|
|绕坐标轴旋转的旋转矩阵|Y|Y|Y|Y|
|绕任意轴旋转的旋转矩阵|Y|Y|Y|Y|
|按坐标轴缩放的缩放矩阵|Y|Y|Y|N|
|错切矩阵|Y|Y|Y|N|
|镜像矩阵|Y|Y|Y|Y|
|正交投影矩阵|Y|Y|N|N|
|透视投影矩阵|N|N|N|N|

##### 齐次坐标

齐次坐标是一个多维矢量(为解决 `3x3` 矩阵不能表示平移操作的问题时拓展到 `4x4` 矩阵，即四维矢量，用一个 `4x4` 的矩阵来表示平移、旋转和缩放)。对于一个点，从三维坐标转换成齐次坐标是把其 `w` 分量设为 `1`, 而对于方向矢量来说，需要把其 `w` 分量设为 `0`。

##### 基础变换矩阵

把表示**纯平移、纯旋转、纯缩放**的变换矩阵叫做基础变换矩阵。这些矩阵具有一些共同点——可以把一个基础变换矩阵分解成 4 个组成部分：

```cs
⎡ M(3x3) t(3x1) ⎤
⎣ 0(1x3) 1      ⎦
```

`M_(3x3)` 表示旋转和缩放，`t(3x1)` 表示平移，`0(1x3)` 是零矩阵 `[0 0 0]`，右下角是标量 `1`

##### 平移矩阵

使用矩阵乘法来表示对一个点进行平移变换：

```cs
  ⎡ 1 0 0 tx ⎤⎡ x ⎤   ⎡ x+tx ⎤
  ⎢ 0 1 0 ty ⎥⎢ y ⎥ = ⎢ y+ty ⎥
  ⎢ 0 0 1 tz ⎥⎢ z ⎥   ⎢ z+tz ⎥
  ⎣ 0 0 0 1  ⎦⎣ 1 ⎦   ⎣ 1    ⎦
```

对一个方向矢量进行平移变换，平移变换不会对方向矢量产生任何影响(因为矢量没有位置属性)。

```cs
  ⎡ 1 0 0 tx ⎤⎡ x ⎤   ⎡ x ⎤
  ⎢ 0 1 0 ty ⎥⎢ y ⎥ = ⎢ y ⎥
  ⎢ 0 0 1 tz ⎥⎢ z ⎥   ⎢ z ⎥
  ⎣ 0 0 0 1  ⎦⎣ 0 ⎦   ⎣ 0 ⎦
```

平移矩阵的逆矩阵：反向平移得到的矩阵

```cs
  ⎡ 1 0 0 -tx ⎤
  ⎢ 0 1 0 -ty ⎥
  ⎢ 0 0 1 -tz ⎥
  ⎣ 0 0 0 1   ⎦
```

##### 缩放矩阵

使用矩阵乘法来表示一个缩放变换：

```cs
  ⎡ kx 0 0 0 ⎤⎡ x ⎤   ⎡ xkx ⎤
  ⎢ 0 ky 0 0 ⎥⎢ y ⎥ = ⎢ yky ⎥
  ⎢ 0 0 kz 0 ⎥⎢ z ⎥   ⎢ zkz ⎥
  ⎣ 0 0 0  1 ⎦⎣ 1 ⎦   ⎣ 1   ⎦
```

对方向矢量可以使用同样的矩阵进行缩放：

```cs
  ⎡ kx 0 0 0 ⎤⎡ x ⎤   ⎡ xkx ⎤
  ⎢ 0 ky 0 0 ⎥⎢ y ⎥ = ⎢ yky ⎥
  ⎢ 0 0 kz 0 ⎥⎢ z ⎥   ⎢ zkz ⎥
  ⎣ 0 0 0  1 ⎦⎣ 0 ⎦   ⎣ 0   ⎦
```

如果缩放系数 `kx = ky = kz`，我们把这样的缩放称为**统一缩放(uniformscale)**, 否则称为**非统一缩放(nonuniformscale)**。

缩放矩阵的逆矩阵：使用原缩放系数的倒数(只适用于沿坐标轴方向进行缩放)
我们希望在任意方向上进行缩放，就需要使用一个**复合变换**。其中一种方法的主要思想就是，先将缩放轴变换成标准坐标轴，然后进行沿坐标轴的缩放，再使用逆变换得到原来的缩放轴朝向。

```cs
  ⎡ 1/kx 0    0    0 ⎤
  ⎢ 0    1/ky 0    0 ⎥
  ⎢ 0    0    1/kz 0 ⎥
  ⎣ 0    0    0    1 ⎦
```

##### 旋转矩阵

- 使用下面的矩阵把点绕着 x 轴旋转 θ 度：

```cs
        ⎡ 1 0    0     0 ⎤
Rx(θ) = ⎢ 0 cosθ -sinθ 0 ⎥
        ⎢ 0 sinθ cosθ  0 ⎥
        ⎣ 0 0    0     1 ⎦
```

- 使用下面的矩阵把点绕着 y 轴旋转 θ 度：

```cs
        ⎡ cosθ  0 sinθ 0 ⎤
Ry(θ) = ⎢ 0     1 0    0 ⎥
        ⎢ -sinθ 0 cosθ 0 ⎥
        ⎣ 0     0 0    1 ⎦
```

- 使用下面的矩阵把点绕着 z 轴旋转 θ 度：

```cs
        ⎡ cosθ  -sinθ 0 0 ⎤
Rz(θ) = ⎢ sinθ  cosθ  0 0 ⎥
        ⎢ 0     0     1 0 ⎥
        ⎣ 0     0     0 1 ⎦
```

旋转矩阵的逆矩阵是旋转相反角度得到的变换矩阵。旋转矩阵是正交矩阵，而且多个旋转矩阵之间的串联同样是正交的。

##### 复合变换

把平移、旋转和缩放组合起来，所形成的一个复杂的变换过程。在绝大多数情况下，我们**约定**变换的顺序就是**先缩放，再旋转，最后平移**。

`P(new)= M(transiation)M(rotation)M(scale)P(old)`

由于上面我们使用的是列矩阵，因此**阅读顺序是从右到左**，即先进行缩放变换，再进行旋转变换，最后进行平移变换。除了需要注意不同类型的变换顺序外，还需要小心旋转的变换顺序。当我们直接给出 `(θx,θy,θz)` 这样的旋转角度时，需要定义一个旋转顺序。在 Unity 中，这个旋转顺序是`zxy`。

- 旋转方式一：进行一次旋转时不一起旋转当前坐标系(Unity文档中说明的旋转顺序)。
- 旋转方式二：在旋转时，把坐标系一起转动。

旋转方式一按 `zxy` 顺序旋转将会和旋转方式二按 `yxz` 顺序旋转得到同样的结果。

#### 坐标空间

##### 空间坐标变换

假设，现在有父坐标空间 P 以及一个子坐标空间 C。一般会有两种需求：一种需求是把子坐标空间下表示的点或矢量 Ac 转换到父坐标空间下的表示 Ap, 另一个需求是反过来，即把父坐标空间下表示的点或矢量 Bp 转换到子坐标空间下的表示 Bc。

- 子坐标空间到父坐标空间的变换矩阵 `M(c-p)`

推导过程：

```cs
// Oc: 原点位置
// Xc、Yc、Zc: 坐标空间 C 的3个坐标轴在父坐标空间 P 下的表示
// Ac = (a,b,c)
// `|` 符号表示列矩阵
Ap = Oc + aXc + bYc + cZc

                       ⎡ Xxc Xyc Xzc ⎤⎡ a ⎤
   = (Xoc, Yoc, Zoc) + ⎢ Yxc Yyc Yzc ⎥⎢ b ⎥
                       ⎣ Zxc Zyc Zzc ⎦⎣ c ⎦

                          ⎡ |  |  |  0 ⎤⎡ a ⎤
                          ⎢ Xc Yc Zc 0 ⎥⎢ b ⎥
   = (Xoc, Yoc, Zoc, 1) + ⎢ |  |  |  0 ⎥⎢ c ⎥
                          ⎣ 0  0  0  1 ⎦⎣ 1 ⎦

     ⎡ 1  0  0  Xoc ⎤⎡ |  |  |  0 ⎤⎡ a ⎤
     ⎢ 0  1  0  Yoc ⎥⎢ Xc Yc Zc 0 ⎥⎢ b ⎥
   = ⎢ 0  0  1  Zoc ⎥⎢ |  |  |  0 ⎥⎢ c ⎥
     ⎣ 0  0  0  1   ⎦⎣ 0  0  0  1 ⎦⎣ 1 ⎦

     ⎡ |  |  |  |  ⎤⎡ a ⎤
     ⎢ Xc Yc Zc Oc ⎥⎢ b ⎥
   = ⎢ |  |  |  |  ⎥⎢ c ⎥
     ⎣ 0  0  0  1  ⎦⎣ 1 ⎦

   = M(c-p)Ac
```

对方向矢量的坐标空间变换不需要表示平移变换，可以使用 3x3 的矩阵来表示。

```cs
         ⎡ |  |  |  ⎤
M(c-p) = ⎢ Xc Yc Zc ⎥
         ⎣ |  |  |  ⎦
```

如果 `M(c-p)` 是一个正交矩阵，`M(p-c) = M-1(p-c) = MT(c-p)`

父坐标空间的坐标轴方向在子坐标空间中的表示 Xp、Yp、Zp 对应矩阵 `M(c-p)` 的每一行

```cs
         ⎡ - Xc - ⎤
M(p-c) = ⎢ - Yc - ⎥
         ⎣ - Zc - ⎦
```

##### 顶点的坐标空间变换

###### 模型空间

也称为**对象空间Cnbject space)**或**局部空间(local space)**。每个模型都有自己独立的坐标空间，当它移动或旋转的时候，模型空间也会跟着它移动和旋转。

###### 世界空间

世界空间(world space) 是一个特殊的坐标系，因为它建立了我们所关心的“最大”的空间。在 Unity 中，世界空间同样使用了左手坐标系，但它的x轴、y轴、z轴是固定不变的。

Unity 中，我们可以通过调整 Transform 组件中的 Position 属性来改变模型的位置，这里的位置值是相对于这个 Transform 的父节点(parent)的模型坐标空间中的原点定义的。如果一个 Transform 没有任何父节点，那么这个位置就是在世界坐标系中的位置。

> **模型变换(model transform)**：将顶点坐标从模型空间变换到世界空间中，是**顶点变换的第一步**。

```cs
// 模型变换计算示例：
// 模型坐标为 (0,2,4)
// 在世界空间中进行了(2,2,2)的缩放又进行了(0,150,0)的旋转以及(5,0,25)的平移。

// 1. 求变换矩阵

           ⎡ 1  0  0  tx ⎤⎡ cosθ   0   sinθ   0 ⎤⎡ kx  0   0  0 ⎤
           ⎢ 0  1  0  ty ⎥⎢ 0      1   0      0 ⎥⎢ 0   ky  0  0 ⎥
M(model) = ⎢ 0  0  1  tz ⎥⎢ -sinθ  0   cosθ   0 ⎥⎢ 0   0   kz 0 ⎥
           ⎣ 0  0  0  1  ⎦⎣ 0      0   0      1 ⎦⎣ 0   0   0  1 ⎦

           ⎡ 1  0  0  5  ⎤⎡ -0.866  0   0.5     0 ⎤⎡ 2   0   0  0 ⎤
           ⎢ 0  1  0  0  ⎥⎢ 0       1   0       0 ⎥⎢ 0   2   0  0 ⎥
         = ⎢ 0  0  1  25 ⎥⎢ -0.5    0   -0.866  0 ⎥⎢ 0   0   2  0 ⎥
           ⎣ 0  0  0  1  ⎦⎣ 0       0   0       1 ⎦⎣ 0   0   0  1 ⎦

           ⎡ -1.372  0  1       5  ⎤
         = ⎢ 0       2  0       0  ⎥
           ⎢ -1      0  -1.372  25 ⎥
           ⎣ 0       0  0       1  ⎦

// 2. 求世界坐标
P(world) = M(model)P(model)

           ⎡ -1.372  0  1       5  ⎤⎡ 0 ⎤
         = ⎢ 0       2  0       0  ⎥⎢ 2 ⎥
           ⎢ -1      0  -1.372  25 ⎥⎢ 4 ⎥
           ⎣ 0       0  0       1  ⎦⎣ 1 ⎦

           ⎡ 9      ⎤
         = ⎢ 4      ⎥
           ⎢ 18.072 ⎥
           ⎣ 1      ⎦
```

###### 观察空间

**观察空间(view space)**也被称为**摄像机空间(camera space)**。观察空间可以认为是模型空间的一个特例——摄像机的模型空间。在观察空间中使用的是**右手坐标系**，在使用 `Camera.cameraToWorldMatrix` `Camera.worldToCameraMatrix` 等接口自行计算模型在观察空间中的位置时需要特别注意左右手坐标系的差异。

> **观察变换(view transform)**：将顶点坐标从世界空间变换到观察空间中，是**顶点变换的第二步**。

得到观察变换矩阵的两种方法：

- 计算观察空间的三个坐标轴在世界空间下的表示，然后构建变换矩阵
- 想象平移整个观察空间，其核心就是将摄像机想象移动到与世界坐标重合的位置，再对z轴分量取反

```cs
// 变换矩阵
// TODO: 这里公式可能有点问题，待验证
           ⎡ 1  0  0   0 ⎤⎡ kx  0  0   0 ⎤⎡ 0   0   0   0 ⎤⎡ 1  0  0  tx ⎤
           ⎢ 0  1  0   0 ⎥⎢ 0  ky  0   0 ⎥⎢ 0   0   0   0 ⎥⎢ 0  1  0  ty ⎥
M(view) =  ⎢ 0  0  -1  0 ⎥⎢ 0  1   kz  0 ⎥⎢ 0   0   0   0 ⎥⎢ 0  0  1  tz ⎥
           ⎣ 0  0  0   1 ⎦⎣ 0  0   0   1 ⎦⎣ 0   0   0   1 ⎦⎣ 0  0  0  1  ⎦
```

###### 裁切空间

裁剪空间 (clip space, 也被称为齐次裁剪空间）中，这个用于变换的矩阵叫做**裁剪矩阵 (clip matrix)**，也被称为**投影矩阵 (projection matrix)**。

**顶点变换的第三步**，裁剪空间的目标是能够方便地对渲染图元进行裁剪：完全位于这块空间内部的图元将会被保留，完全位于这块空间外部的图元将会被剔除，而与这块空间边界相交的图元就会被裁剪。这块空间由**视锥体 (view frustum)** 来决定。

视锥体有两种类型，这涉及两种投影类型：正交投影 (orthographic projection)和透视投影 (perspective projection)。

![透视投影（左图）和正交投影（右图）。左下角分别显示了当前摄像机的投影模式和相关属性](http://static.zybuluo.com/candycat/wqkekwazaaordawbq21nj7hz/camera_projection.png)

![ 视锥体和裁剪平面。左图显示了透视投影的视锥体，右图显示了正交投影的视锥体](http://static.zybuluo.com/candycat/b6wiym3nlkwimvnvgjgohhbz/camera_frustum.png)

根据视锥体围成的区域对图元进行裁剪时，我们通过一个**投影矩阵**（目的：1、为投影做准备 2、对x、y、z分量进行缩放）把顶点转换到裁剪空间中。

###### 屏幕空间

屏幕空间是二维空间，经过视锥体投影到屏幕空间(screen space) 这一步变换，我们会得到真正的像素位览，而不是虚拟的三维坐标。

- 步骤一：

  进行标准**齐次除法(homogeneousdivision)**，也被称为透视除法(perspective division)，用齐次坐标系的 `w` 分量去除以x、y、z分量。在 OpenGL 中，这一步得到的坐标叫做**归一化的设备坐标(Normalized Device Coordinates, NDC)**。
  
  经过这一步，我们可以把坐标从齐次裁剪坐标空间转换到 NDC 中。经过透视投影变换后的裁剪空间，经过齐次除法后会变换到一个立方体内。按照 OpenGL 的传统，这个立方体的x、y、z分扭的范围都是[-1,1]。但在 DirectX 这样的 API 中，z 分量的范围会是[0,1]。而 Unity 选择了 OpenGL 这样的齐次裁剪空间。

  ![经过齐次除法后，透视投影的裁剪空间会变换到一个立方体 ](http://static.zybuluo.com/candycat/7ozeba0c8nex3o4zr9z9nt4v/projection_matrix1.png)

  ![经过齐次除法后，正交投影的裁剪空间会变换到一个立方体](http://static.zybuluo.com/candycat/8921u8zbn1m38conxbed0nz5/orthographic_matrix1.png)

  在 Unity 中，屏幕空间左下角的像素坐标是`(0, 0)`, 右上角的像素坐标是`(pixelWidth, pixelHeight)`。由于当前x和y坐标都是`[-1, 1]`, 因此这个映射的过程就是一个缩放的过程。

- 步骤二：

  根据变换后的x和y坐标来映射输出窗口的对应像素坐标。

  齐次除法和屏幕映射的过程可以使用下面的公式来总结：

  ```cs
  // x 分量
  screen(x) = clip(x)·pixelWidth/(2·clip(w)) + pixelWidth/2
  
  // y 分量
  screen(y) = clip(y)·pixelHeight/(2·clip(w)) + ·pixelHeight/2

  // z 分量会被用于深度缓冲。
  ```

在 Unity 中，从裁剪空间到屏幕空间的转换是由 Unity 帮我们完成的。我们的顶点着色器只需要把顶点转换到裁剪空间即可。

#### 法线变换

当我们变换一个模型的时候，不仅需要变换它的顶点，还需要**变换顶点法线**，以便在后续处理（如片元着色器）中计算光照等。

变换矩阵推导：

```cs
// 我们使用 3x3 的变换矩阵M(A-B)来变换顶点
// 1. 切线变换
// T(A)和T(B)分别表示在坐标空间A下和坐标空间B下的切线方向
T(B) = M(A-B)T(A)

// 2. 同一个顶点的切线T(A)和法线N(A)必须满足垂直条件
T(A)·N(A) = 0

// 3. 欲求矩阵G来变换法线N(A)得到坐标空间B下法线N(B)
T(B)·N(B) = [M(A-B)T(A)]·[GN(A)] = 0

// 中间的变换实在是看不懂直接上结果
G = [M(A-B)^T]^-1 = [M(A-B)^-1]^T

// 如果变换矩阵 M(A-B) 是正交矩阵(如只有旋转变换)
G = M(A-B)

// 如果变换包括旋转和同一缩放k
G = M(A-B)/k
```

### unity Shader 的内置变量

#### 变换矩阵

***Unity内置的变换矩阵(float4x4)***

| 变量名 | 描述 |
| ----- | ---- |
| `UNITY_MATRIX_MVP` | 当前的模型·观察·投影矩阵，用于将顶点/方向矢量从模型空间变换到裁剪空间 |
| `UNITY_MATRIX_MV` | 当前的模型·观察矩阵，用于将顶点/方向矢量从模型空间变换到观察空间 |
| `UNITY_MATRIX_V` | 当前的观察矩阵，用于将顶点/方向矢量从世界空间变换到观察空间 |
| `UNITY_MATRIX_P` | 当前的投影矩阵，用于将顶点/方向矢量从观察空间变换到裁剪空间 |
| `UNITY_MATRIX_VP` | 当前的观察·投影矩阵，用于将顶点/方向矢量从世界空间变换到裁剪空间
UNITY_MATRIX_ |
| `UNITY_MATRIX_T_MV` | `UNITY_MATRIX_MV` 的转置矩阵 |
| `UNITY_MATRIX_IT_MV` | `UNITY_MATRIX_MV` 的逆转置矩阵，用于将法线从模型空间变换到观察空间，也可用于得到 `UNITY_MATRIX_MV` 的逆矩阵 |
| `_Object2World` | 当前的模型矩阵，用于将顶点/方向矢量从模型空间变换到世界空间 |
| `_World20bject` | `_Object2World` 的逆矩阵，用于将顶点/方向矢量从世界空间变换到模型空间 |

> 矩阵 `UNITY_MATRIX_IT_MV` 特殊说明：

```cs
// 方法一：
// 使用 transpose 函数对 UNITY_MATRIX_IT_MV 进行转置，
// 得到 UNITY_MATRIX_MV 的逆矩阵，然后进行列矩阵乘法，
// 把观察空间中的点或方向矢量变换到模型空间中
float4 modelPos = mul(transpose(UNITY_MATRIX_IT_MV), viewPos);

// 方法二：
// 不直接使用转置函数 transpose, 而是交换 mul 参数的位置，使用行矩阵乘法
// 本质和方法一是完全一样的
float4 modelPos : mul(viewPos, UNITY_MATRIX_IT_MV);
```

#### 摄像机和屏幕参数

***Unity 内置的摄像机和屏幕参数***

| 变量名 | 类型 | 描述 |
| ----- | ---- | --- |
| `_WorldSpaceCameraPos` | float3 | 该摄像机在世界空间中的位置 |
| `_ProjectionParams` | float4 | `x = 1.0` (或-1.0，如果正在使用一个翻转的投影矩阵进行渲染)，`y = Near`，`z = Far`，`w = 1.0+1.0/Far`，其中 Near 和 Far 分别是近裁切平面和远裁切平面和摄像机的距离 |
| `_ScreenParams` | float4 | `x = width`, `y = height`, `z = 1.0 + 1.0/width`, `w = 1.0 + 1.0/height`, 其中 width 和 height 分别是该摄像机的渲染目标 (render target) 的像素宽度和高度 |
| `_ZBufferParams` | float4 | `x = 1- Far/Near`, `y= Far/Near`, `z = x/Far`, `w = y/Far`, 该变量用于线性化 Z 缓存中的深度值 |
| `unity_OrthoParams`  | float4 | `x = width`, `y = height`, z 没有定义，`w = 1.0` (该摄像机是正交摄像机）或 `w = 0.0` (该摄像机是透视摄像机），其中 width 和 height 是正交投影摄像机的宽度和高度 |
| `unity_CameraProjection`  | float4x4 | 该摄像机的投影矩阵 |
| `unity_CameraInvProjection`  | float4x4 | 该摄像机的投影矩阵的逆矩阵 |
| `unity_CameraWorldClipPlanes[6]`  | float4 | 该摄像机的6个裁剪平面在世界空间下的等式，按如下顺序：左、右、 下、上、近、远裁剪平面 |

#### CG 语言中的矢量和矩阵

在CG中，矩阵类型是由 `float3x3`、`float4x4` 等关键词进行声明和定义的。而对于 `float3`、`float4` 等类型的变量，我们既可以把它当成一个矢量，也可以把它当成是一个 `1xn` 的行矩阵或者一个 `nx1` 的列矩阵。这取决于运算的种类和它们在运算中的位置(例如点积属于矢量操作)。

- 在进行矩阵乘法时，参数的位置将决定是按列矩阵还是行矩阵进行乘法。在CG中，矩阵 乘法是通过 `mul` 函数实现的。

```cs
mul(M,v) == mul(v, tranpose(M))
mul(v,M) = mul(tranpose(M), v)
```

- CG 使用的是**行优先**的方法去填充矩阵，且访问一个矩阵中的元素时，也是**按行索引**的。
- Unity 在脚本中提供了一种矩阵类型 `Matrix4x4`，这个矩阵类型则是采用**列优先**的方式。

#### Unity 中的屏幕坐标：ComputeScreenPos/VPOS/WPOS

在顶点/片元着色器中获得片元的屏幕坐标的方法：

- 方法1. 在片元着色器的输入中声明 VPOS 或 WPOS 语义(VPOS 是 HLSL 中对屏幕坐标的语义，而 WPOS 是 CG 中对屏幕坐标的语义)

```cs
fixed4 frag(float4 sp : VPOS) : SV_Target {
  // 用屏幕坐标除以屏幕分辨率 _ScreenParams.xy 得到视口空间中的坐标
  // 视口坐标：屏幕坐标归一化，屏幕左下角就是(0, 0),右上角就是(1, 1)。
  return fixed4(sp.xy/_ScreenParams.xy, 0.0, 1.0);
}
```

- 方法2. 使用 `UnityCG.cginc` 中定义的 `ComputeScreenPos` 函数。首先在顶点着色器中将 `ComputeScreenPos` 的结果保存在输出结构体中，然后在片元着色器中进行一个齐次除法运算后得到视口空间下的坐标。这种方法实际上是手动实现了屏幕映射的过程，而且它得到的坐标直接就是视口空间中的坐标。

```cs
struct vertOut {
  float4 pos : SV_POSITION;
  float4 scrPos : TEXCOORD0;
}

vertOut vert(appdata_base v) {
  vertOut o;
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  // 1. 把 ComputeScreenPos 的结果保存到 scrPos 中
  o.scrPos = ComputeScreenPos(o.pos);
  return o;
}

fixed4 frag (vertOut i) : SV_Target {
  // 2. 用 scrPos.xy 除以 scrPos.w 得到视口空间中的坐标
  float2 wcoord = (i.scrPos.xy / i.scrPos.w);
  return fixed4(wcoord, 0.0, 1.0);
}
```

## Shader 基础

### 认识顶点/片元着色器

顶点/片元着色器完整示例代码 [ここてまる](Assets/Shader/Tutorial_Shader_template.shader)

***SimpleShader.shader***

```cs
Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
  SubShader {
    Pass {
      CGPROGRAM

      // 告知 Unity, 哪个函数包含了顶点着色器的代码 `#pragma vertex name`
      #pragma vertex vert
      // 告知 Unity, 哪个函数包含了片元着色器的代码 `#progma fragment name`
      #progma fragment frag

      // POSITION 和 SV_POSITION 都是 CG/HLSL 中的语义 (semantics), 它们是不可省略的，这些语义将告诉系统用户需要哪些输入值，以及用户的输出是什么。
      // POSITION 告诉 Unity, 把模型的顶点坐标填充到输入参数 v 中
      // SV_POSITION 告诉 Unity, 顶点着色器的输出是裁剪空间中的顶点坐标
      float4 vert(float4 v : POSITION) : SV_POSITION {
        returnb mul(UNITY_MATRIX_MVP, v);
      }

      // SV_Target 也是 CG/HLSL 中的语义 (semantics)，它等同于告诉渲染器，把用户的输出颜色存储到一个渲染目标 (render target) 中，这里将输出到默认的帧缓存中。
      fixed4 frag() : SV_Target {
        return fixed4(1.0,1.0,1.0,1.0);
      }

      ENDCG
    }
  }
}
```

材质提供给我们一个可以方便地调节 Unity Shader 中参数的方式，通过这些参数，我们可以随时调整材质的效果。而这些参数就需要写在 `Properties` 语义块中。

```cs
// ...
Properties {
  // 声明格式 `name ("display name",type)=default value`
  _Colour ("_Colour",Color) = (1,1,1,1)
  _MainTexture ("Mian Texture",2D) = "white"{}
  _DissolveTexture ("Dissolve Texture", 2D) = "white" {}
  _DissolveCutoff ("Dissolve Cutoff", Range(0, 1)) = 1
  _ExtrudeAmount ("Extrue Amount", float) = 0
}
// ...
float4 _Colour;
sampler2D _MainTexture;
sampler2D _DissolveTexture;
float _DissolveCutoff;
float _ExtrudeAmount;
// ...
```

***Shaderlab 属性类型和 CG 变量类型的匹配关系***

| Shaderlab属性类型 | CG变量类型 |
| ---------------- | --------- |
| `Color, Vector`  | float4, half4, fixed4 |
| `Range, Float`  | float, half, fixed |
| `2D` | sampler2D |
| `Cube` | samplerCube |
| `3D` | sampler3D |

### Unity 内置文件和变量

Unity 内置文件和变量 [ここてまる](Unity_Docs.md#HLSL%20片段)

### 语义(semantic)

参考文档 [Semantics](https://docs.microsoft.com/en-us/windows/desktop/direct3dhlsl/dx-graphics-hlsl-semantics)

语义是附加到着色器输入或输出的字符串，用于传达有关参数的预期用途的信息。通俗地讲，这些语义可以让 Shader 知道从哪里读取数据，并把数据输出到哪里。

#### 系统数值

在 DirectX 10 以后，有一种新的语义类型，就是**系统数值语义 (system-value semantics)**。这类语义是以 `SV` 开头的，`SV` 代表的含义就是**系统数值 (system-value)**。这些语义在渲染流水线中有特殊的含义。为了让 Shader 有更好的跨平台性，对于这些有特殊含义的变量最好使用以 `SV` 开头的语义进行修饰。

#### Unity 支持的语义

***从应用阶段传递模型数据给顶点着色器时Unity支持的常用语义***

| 语义 | 描述 |
| ---- | --- |
| `POSITION` | 模型空间中的项点位置，通常是 float4 类型 |
| `NORMAL`  | 顶点法线，通常是 float3 类型 |
| `TANGENT`  | 顶点切线，通常是 float4 类型 |
| `TEXCOORDn` | 顶点的纹理坐标，`TEXCOORDn` 表示第 n 组纹理坐标，通常是 float2 或 float4 类型(n 的数目和 Shader Model 有关) |
| `COLOR`  | 顶点颜色，通常是 fixed4 或 float4 类型 |

***从顶点着色器传递数据给片元着色器时Unity使用的常用语义***

| 语义 | 描述 |
| ---- | --- |
| `SV_POSITION` | 裁切空间中的顶点坐标，结构体中必须包含一个用于该语义修饰的变量。等同于 DirectX9 中的 `POSITION`，但最好使用 `SV_POSITION` |
| `COLOR0` | 通常用于输出第一组顶点颜色．但不是必需的 |
| `COLOR1` | 通常用于输出第二组顶点颜色，但不是必需的 |
| `TEXCOORD0~TEXCOORD7` | 通常用于输出纹理坐标，但不是必需的 |

通常，如果我们需要把一些自定义的数据从顶点着色器传递给片元着色器，一般选用`TEXCOORD0`

***片元着色器输出时Unity支持的常用语义***

| 语义 | 描述 |
| ---- | --- |
| `SV_Target`  | 输出值将会存储到渲染目标 (render target) 中。等同于 DirectX9 中的 `COLOR` 语义，但最好使用 `SV_Target` |

ps: 应该尽可能使用下面的语义来描述Shader的输入输出变量。

- 使用 `SV_POSITION` 来描述顶点着色器输出的顶点位置。一些 Shader 使用了 `POSITION` 语义，但这些 Shader 无法在索尼 PS4 平台上或使用了细分着色器的情况下正常工作。
- 使用 `SV_Target` 来描述片元着色器的输出颜色。一些 Shader 使用了 `COLOR` 或者 `COLOR0` 语义，同样的，这些 Shader 无法在索尼 PS4 上正常工作。

#### 复杂变量类型定义

一个语义可以使用的寄存器只能处理 4 个浮点值(float)。因此，如果我们想要定义矩阵类型，如float3x4、float4x4 等变弑就需要使用更多的空间。一种方法是，把这些变量拆分成多个变量，例如对于 float4x4 的矩阵类型，我们可以拆分成 4 个float4 类型的变量，每个变量存储了矩阵中的一行数据。

### 渲染平台的差异

#### 渲染纹理的坐标差异

- OpenGL 和 DirectX 的屏幕空间坐标的差异：
  
  在水平方向上，两者的数值变化方向是相同的，但在竖直方向上，两者是相反的。在 OpenGL (OpenGL ES 也是)中，`(0, 0)` 点对应了屏幕的左下角，而在 DirectX (Metal 也是）中，`(0, 0)` 点对应了左上角。

  ![OpenGL和DirectX使用了不同的屏幕空间坐标](http://static.zybuluo.com/candycat/ninmtxykcrk7oywzvxirhn04/2d_cartesian_opengl_directx.png)

- 使用渲染纹理 (Render Texture) 时：

  把渲染结果输出到不同的渲染目标 (Render Target) 中时，需要使用渲染纹理来保存这些渲染结果。如果不采取行任何措施的话，就会出现纹理翻转的情况。然而，Unity 在背后会为我们**自动**处理这种翻转问题。
  
  有一种特殊情况 Unity 不会进行这个翻转操作，这种情况就是我们开启了抗锯齿。
  - 如果屏幕特效只需要处理**一张**渲染图像，不需要在意纹理的翻转问题，这是因为在我们调用 `Graphics.Blit` 函数时，Unity 已经为我们对屏幕图像的采样坐标进行了处理，我们只需要按正常的采样过程处理屏幕图像即可。
  - 如果屏幕特效只需要处理**多张**渲染图像，这些图像在竖直方向的朝向可能不同（仅 DirectX 才会有此问题），此时需要自行处理：

  ```cs
  #if UNITY_UV_STARTS_AT_TOP // 判断当前平台是否是 DirectX 类型的平台
  if(_MainTex_TexelSize.y < 0) // 开启了抗锯齿后，主纹理的纹素大小在竖直方向上会变成负值，_MainTex_TexelSize.y < 0 来检验是否开启了抗锯齿
  {
    ux.y = 1 - uv.y; // 对除主纹理外的其他纹理的采样坐标进行竖直方向上的翻转
  }
  #endif
  ```

  ps: 类似噪声纹理的装饰性纹理，它们在竖直方向上的朝向并不是很重要，即便翻转了效果往往也是正确的，因此我们可以不对这些纹理进行平台差异化处理。

### Shader 代码规范

#### float, half, fixed

`float, half, fixed` 是 CG/HLSL 中的 3 种精度的数值类型，这些精度将决定计算结果的数值范围。

***CG/HLSL 中的 3 种精度的数值类型（精度范围并不是绝对正确）***

| 类型 | 精度 |
| ---- | --- |
| `float` | 最高精度的浮点值。通产用 32 位存储 |
| `half`  | 中等精度的浮点值。通产用 16 位存储，精度范围 -60000~+60000 |
| `fixed` | 最低精度的浮点值。通产用 11 位存储，精度范围 -2.0~+2.0 |

ps: 尽可能使用精度较低的类型，因为这可以优化 Shader 的性能，这一点在移动平台上尤其重要。从它们大体的值域范围来看，我们可以使用 `fixed` 类型来存储颜色和单位矢量，如果要存储更大范围的数据可以选择 `half` 类型，最差情况下再选择使用 `float`。

#### 避免不必要的计算

过多的运算可能导致需要的临时寄存器数目或指令数目超过了当前可支持的数目而引发异常。通常，我们可以通过指定更高等级的 Shader Target 来消除这些错误。但一个更好的方法是尽可能减少Shader中的运算，或者通过预计算的方式来提供更多的数据。

***Unity支持的Shader Target***

| 指令 | 描述 |
| --- | ---- |
| #pragma target 2.0 | 默认的 Shader Target 等级。相当于 Direct3D 9 上的 Shader Model 2.0  |
| #pragma target 3.0 | 相当于 Direct3D 9 上的 Shader Model 3.0  |
| #pragma target 4.0 | 相当于 Direct3D 10 上的 Shader Model 4.0。目前只在 DirectX ll 和 Xbox0ne/PS4 平台上提供了支持 |
| #pragma target 5.0 | 相当于 Direct3D 11 上的 Shader Model 5.0。目前只在 DirectX 11 和 Xbox0ne/PS4 平台上提供了 支持 |

ps: 所有类似 OpenGL 的平台（包括移动平台）被当成是支持到 Shader Model 3.0 的。而 WP8/WinRT 平台则只支持到 Shader Model 2.0。

#### 慎用分支和循环语句

- 分支语句
  GPU 使用了不同于 CPU 的技术来实现分支语句。在最坏的情况下，花在一个分支语句的时间相当于运行了所有分支语句的时间。这样会降低 GPU 的并行处理操作。
- 流程控制语句
  在 Shader 中使用大量的流程控制语句时，这个 Shader 的性能可能会成倍下降。一个解决方法是：该尽量把计算向流水线上端移动。例如把放在片元着色器中的计算放到顶点着色器中。或者直接在 CPU 中进行预计算。再把结果传递给 Shader。当无法避免使用分支语句进行计算时：
  - 分支判断语句中使用的条件变量最好是常数，即在Shader运行过程中不会发生变化
  - 每个分支中包含的操作指令数尽可能少
  - 分支的嵌套层数尽可能少。
  
## Unity的基础光照

### 一些光学概念

- 辐照度(irradiance)

  量化光的指标，是在某一指定表面上单位面积上所接受的辐射能量。单位：瓦特/平方米。

- 散射(scattering)和吸收(absorption)

  光线在物体表面经过散射后，有两种方向：一种将会散射到物体内部，这种现象被称为**折射(refraction)**或**透射(transmission)**; 另一种将会散射到外部，这种现象被称为**反射(reflection)**。对于不透明物体，折射进入物体内部的光线还会继续与内部的颗粒进行相交，其中一些光线最后会重新发射出物体表面，而另一些则被物体**吸收**。那些从物体表面重新发射出的光线将具有和入射光线不同的方向分布和颜色。

  ![散射时，光线会发生折射和反射现象。对于不透明物体，折射的光线会在物体内部继续传播，最终有一部分光线会重新从物体表面被发射出去](http://static.zybuluo.com/candycat/7gu6p5xdmzngz53iaa011joy/scattering.png)

  在光照模型中，**高光反射(specular)** 部分表示物体表面是如何反射光线的，而**漫反射(diffuse)** 部分则表示有多少光线会被折射、 吸收和散射出表面。

- 着色(shading)

  根据材质属性（如漫反射屈性等）、光源信息（如光源方向、辐照度等），使用一个等式去计算沿某个观察方向的出射度的过程。这个等式成为**光照模型(Lighting Model)**。

### 标准光照模型

#### 标准光照模型的四部分

标准光照模型只关心直接光照（direct light）。它把进入摄像机的光照分为4个部分，每个部分使用一种方法来计算它的贡献度。

- **自发光（emissive）**，这部分用于给定一个方向时，物体表面会向这个方向产生多少的光（辐射量），当没有使用全局光照时，自发光物体不会照亮周围物体，只是本身看起来更亮而已。

  计算自发光非常简单，只需要在片元着色器输出最后的颜色之前，把材质的自发光颜色添加到输出颜色上即可。
- **高光反射（specular）**，这个部分用于描述当光线从光源照到物体表面时，物体镜面反射产生的光。

  计算高光反射需要知道**表面法线、视角方向、光源方向、反射方向**，其中反射方向可以通过其他三个向量计算得到。

  ```cs
  // 计算反射方向 r
  r = 2 (N·I)N - I

  // 利用 Phong 模型来计算高光反射
  // c(light) 是光源颜色和强度
  // m(gloss) 是材质的光泽度(gloss), 也被称为反光度(shininess)
  // V 是视角方向(View)
  // m(specular)是材质的高光反射系数(Material Specular)，用于控制该材质对于高光反射的强度和颜色
  c(specular) = [c(light)·m(specular)]max(0,V·r)^m(gloss)

  // 利用 Blinn 模型来计算高光反射(避免计算反射方向 r)
  // 引入新矢量 h
  h = (V+I) / |V+I|
  c(specular) = [c(light)·m(specular)]max(0,V·h)^m(gloss)
  ```

- **漫反射（diffuse）**，这个部分是光线从光源照到物体表面时，物体向各个方向产生的光。

  漫反射光照符合**兰伯特定律(Lambert's law)**: 反射光线的强度与表面法线和光源方向之间夹角的余弦值成正比。

  ```cs
  // 计算漫反射
  // n 是表面法线，I 是指向光源的单位矢量
  // m(diffuse) 是材质的漫反射颜色，c(light) 是光源颜色和强度
  c(diffuse) = [c(light)·m(diffuse)]max(O,n · I)
  ```

- **环境光（ambient）**，这个部分用来描述其他间接的光。

  在标准光照模型中，我们使用了一种被称为环境光的部分来近似模拟间接光照。环境光的计算非常简单，它通常是一个全局变量，即场景中的所有物休都使用这个环境光。通常在实时渲染中，自发光的表面往往并不会照亮周围的表面，也就是说，这个物体并不会被当成一个光源。

  ```cs
  // 计算环境光
  c(ambient) = g(ambient)
  ```

#### 半兰伯特(HalfLambert)光照模型

半兰伯特是没有任何物理依据的，它仅仅是一个视觉加强技术。

广义的半兰伯特光照模型的公式：

```cs
// (绝大多数情况下，α，β值均为 0.5)
c(diffuse) = [c(light)·m(diffuse)](α(n · I)+β)
```

#### 光照模型计算着色器

- **片元着色器**：也叫**逐像素光照（per-pixel lighting）**。一般以每个像素为基础，得到它的法线（可以是对顶点法线插值得到，也可以从纹理法线中采样得到），然后进行光照模型计算。这种在面片之间对顶点法线进行插值的技术被称为**Phong着色(Phong shading)**, 也被称为**Phong插值**或**法线插值**着色技术
- **顶点着色器**：也叫**逐顶点光照（per-vertex lighting）**。是在每个顶点上计算光照，然后在渲染图元内部进行线性插值，最后输出成像素颜色。**高洛德着色(Gouraud shading)**。

由于顶点数目远小于像素数目，因此逐顶点光照的计算量要小于逐像素光照。但是，由于逐顶点光照依赖于线性插值来得到像素光照，所以当光照模型中有非线性的计算时（计算高光反射），逐顶点就会出问题。而且由于逐顶点光照会在渲染图元内部对顶点颜色进行插值，会导致渲染图元内部颜色总是暗于顶点处的最高颜色值，这在某些情况下会产生明显的棱角现象。

### Unity Shader 中实现漫反射光照模型

基本光照模型中漫反射部分的计算公式：`c(diffuse) = [c(light)·m(diffuse)]max(0 ,n · I)`

#### 实现逐顶点光照

```cs
Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level" {
  Properties {
    _Diffuse ("Diffuse", Color) = (1,1,1,1)
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Diffuse;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        fixed3 color : COLOR;
      };

      v2f vert(a2v v) {
        v2f o;
        // 顶点着色器最基本的任务: 把顶点位置从模型空间转换到裁剪空间中
        o.pos = UnityObjectToClipPos(v.vertex);
        // 得到了环境光部分
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        // 得到光源方向(这里对光源方向的计算并不具有通用性)
        fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
        // 把法线转换到世界空间(这里使用顶点变换矩阵的逆转置矩阵对法线进行相同的变换)并归一化
        // 法线是一个三维矢量，所以只需要截取 _World2Object 的前三行前三列
        fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
        // 得到最终的漫反射光照部分
        // saturate函数可以把参数截取到[0, 1]的范围内
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
        o.color = ambient + diffuse;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        return fixed4(i.color, 1.0);
      }

      ENDCG
    }
  }
  Fallback "Diffuse"
}
```

#### 实现逐像素光照

```cs
Shader "Unlit/Chapter6-DiffusePixelLevelMat"
{
  Properties {
    _Diffuse ("Diffuse", Color) = (1,1,1,1)
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Diffuse;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
      };

      v2f vert(a2v v) {
        v2f o;
        // 顶点着色器最基本的任务: 把顶点位置从模型空间转换到裁剪空间中
        o.pos = UnityObjectToClipPos(v.vertex);
        // 把世界空间下的法线传递给片元着色器
        o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
        fixed3 color = ambient + diffuse;
        return fixed4(color, 1.0);
      }

      ENDCG
    }
  }
  Fallback "Diffuse"
}

```

### Unity Shader 中实现高光反射光照模型

基本光照模型中高光反射部分的计算公式：

```cs
r = 2 (N·I)N - I
c(specular) = [c(light)·m(specular)]max(0,V·r)^m(gloss)

// or
// Blinn-Phong 光照模型
h = (V+I) / |V+I|
c(specular) = [c(light)·m(specular)]max(0,V·h)^m(gloss)
```

#### 逐顶点光照

使用逐顶点的方法得到的高光效果有比较大的问题，高光部分明显不平滑。这主要是因为，高光反射部分的计算是非线性的，而在顶点着色器中计算光照再进行插值的过程是线性的，破坏了原计算的非线性关系，就会出现较大的视觉问题。

```cs
Shader "Unity Shader Book/Chapter 6/Specular Vertex-Level" {
  Properties {
    _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    // 控制高光反射颜色
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    // 控制高光区域的大小
    _Gloss ("Gloss", Range(8.0, 256)) = 20
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Diffuse;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        fixed3 color : COLOR;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        // 计算漫反射部分
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
        // 计算高光反射部分
        fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
        fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_WorldToObject, v.vertex).xyz);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
        o.color = ambient + diffuse + specular;

        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        return fixed4(i.color, 1.0);
      }
      ENDCG
    }
  }

  Fallback "Specular"
}
```

#### 逐像素光照

使用逐像素光照可以得到更加平滑的高光效果

```cs
Shader "Unity Shader Book/Chapter 6/Specular Vertex-Level" {
  Properties {
    _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    // 控制高光反射颜色
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    // 控制高光区域的大小
    _Gloss ("Gloss", Range(8.0, 256)) = 20
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Diffuse;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 计算漫反射部分
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
        // 计算高光反射部分
        fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
        fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
        return fixed4(ambient + diffuse + specular, 1.0);
      }
      ENDCG
    }
  }

  Fallback "Specular"
}
```

#### Blinn-Phong 光照模型

```cs
// 修改逐像素光照的 frag 函数计算高光反射部分
fixed4 frag(v2f i) : SV_Target {
    // ...
    // 计算高光反射部分
    fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 halfDir = normalize(worldLightDir + viewDir);
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
    return fixed4(ambient + diffuse + specular, 1.0);
}
```

### 使用 Unity 内置函数

[UnityCG.cginc中一些常用的帮助函数](Unity_Docs.md#HLSL%20片段)

## 光照进阶

### Unity 的渲染路径

在 Unity 里，**渲染路径(Rendering Path)**决定了光照是如何应用到 Unity Shader 中的。通过使用 `Pass` 指定渲染路径，就可以通过 Unity 提供的内置光照变量来访问这些属性。Unity 支持多种类型的渲染路径。在Unity5.0版本之前，主要有3种：

- 前向渲染路径(Forward Rendering Path)，默认
- 延迟渲染路径 (Deferred Rendering Path)，被新的延迟渲染路径替换
- 顶点照明渲染路径 (Vertex Lit Rendering Path)，已决定废弃

**_LightMode标签支持的渲染路径设置选项_**

| 标签名 | 描述 |
| ----- | --- |
| Always | 不管使用哪种渲染路径，该 Pass 总是会被渲染，但不会计算任何光照 |
| ForwardBase | 用于前向渲染。该 Pass 会计算环境光、最重要的平行光、逐顶点/SH 光源和 Lightmaps |
| ForwardAdd | 用于前向渲染。该 Pass 会计算额外的逐像素光源，每个 Pass 对应一个光源 |
| Deferred | 用于延迟渲染。该 Pass 会渲染 G 缓冲 (G-buffer) |
| ShadowCaster | 把物体的深度信息渲染到阴影映射纹理 (shadowmap) 或一张深度纹理中 |
| PrepassBase | 用于遗留的延迟渲染。该 Pass 会渲染法线和高光反射的指数部分 |
| PrepassFinal | 用于遗留的延迟渲染。该 Pass 通过合并纹理、光照和自发光来渲染得到最后的颜色 |
| Vertex、VertexLMRGBM 和 VertexLM  | 用于遗留的顶点照明渲染 |

#### 前向渲染路径

前向渲染路径是我们_最常用_的一种渲染路径。每进行一次完整的前向渲染，需要渲染该对象的渲染图元，并计算两个缓冲区的信息：一个是颜色缓冲区，一个是深度缓冲区。利用深度缓冲来决定一个片元是否可见，如果可见就更新颜色缓冲区中的颜色值。假设场景中有N个物体，每个物体受 `M` 个光源的影响，那么要渲染整个场景一共需要 `NxM` 个`Pass`，如果有大量逐像素光照，那么需要执行的 `Pass` 数目也会很大。因此，渲染引擎通常会限制每个物体的逐像素光照的数目。

在Unity中，前向渲染路径有3种处理光照（即照亮物体）的方式：**逐顶点处理**、**逐像素处理**，**球谐函数(Spherical Harmonics, SH)**处理。SH)处理。而决定一个光源使用哪种处理模式取决于它的**类型**(平行光还是其他类型的光源)和**渲染模式**(该光源是否是重要的`Important`-> 按逐像素光源处理)。

- 场景中最亮的平行光总是按逐像素处理的。
- 渲染模式被设置成 `Not Important` 的光源，会按逐顶点或者SH处理。
- 渲染模式被设置成 `Important` 的光源，会按逐像素处理。
- 如果根据以上规则得到的逐像素光源数量小于 Quality Setting 中的逐像素光源数量(Pixel Light Count), 会有更多的光源以逐像素的方式进行渲染。

![前向渲染的两种Pass](http://static.zybuluo.com/candycat/575lq2zgnsaop3nw2miyobt3/forward_rendering.png)

**重点说明**：

- 除了需要设置 Pass 的标签，还需要分别使用 `#pragma multi_compile_fwdbase` 和 `#pragma multi_compile_fwdadd` 编译指令才能在相关 Pass 获得正确的光照变量。
- `Base Pass` 中渲染的平行光默认是支持阴影的（如果开启了光源的阴影功能），而`Additional Pass` 中渲染的光源在默认情况下是没有阴影效果的(使用 `#pragma multi_compile_fwdadd_fullshadows` 代替 `#pragma multi_compile_fwdadd` 编译指令，可为点光源和聚光灯开启阴影效果)。
- 环境光和自发光也是在 `Base Pass` 中计算的(环境光和自发光只需计算一次)。
- 一般在 `Additional Pass` 的渲染设置中，需要开启和设置混合模式，防止之前的渲染结果被覆盖。

**_前向渲染可以使用的内置光照变量_**
| 名称 | 类型 | 描述 |
| --- | --- | --- |
| `_LightColor0` | float4 | 该 Pass 处理的逐像素光源的颜色 |
| `_WorldSpaceLightPos0` | float4 | `_WorldSpaceLightPos0.xyz` 是该 Pass 处理的逐像素光源的位置。如果该光源是平行光，那么`_WorldSpaceLightPos0.w` 是 0. 其他光源类型 `w` 值为 1 |
| `_LightMatrix0`  | float4x4 | 从世界空间到光源空间的变换矩阵。可以用于采样 cookie 和光强衰减 (attenuation) 纹理 |
| `unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0`  | float4 | 仅用于 Base Pass。前 4 个非重要的点光源在世界空间中的位置 |
| `unity_4LightAtten0`  | float4 | 仅用于 Base Pass。存储了前 4 个非重要的点光源的衰减因子 |
| `unity_LightColor` | half4[4]  | 仅用于 Base Pass。存储了前 4 个非重要的点光源的颜色 |

**_前向渲染可以使用的内置光照函数_**

| 函数名 | 描述 |
| ----- | --- |
| `float3 WorldSpaceLightDir (float4 v)`  | 仅可用于前向渲染中。输入一个模型空间中的顶点位置，返回世界空间中从该点到光源的光照方向。内部实现使用了 `UnityWorldSpaceLightDir` 函数。没有被归一化 |
| `float3 UnityWorldSpaceLightDir (float4 v)` | 仅可用于前向渲染中。输入一个世界空间中的顶点位置，返回世界空间中从该点到光源的光照方向。没有被归一化 |
| `float3 ObjSpaceLightDir(float4 v)` | 仅可用于前向渲染中。输入一个模型空间中的顶点位置，返回模型空间中从该点到光源的光照方向。没有被归一化 |
| `float3 Shade4PointLights (...)` | 仅可用于前向渲染中。计算四个点光源的光照。它的参数是已经打包进矢量的光照数据，如 `unity_4LightPosX0`, `unity_4LightPosY0`,`unity_4LightPosZ0`,`unity_LightColor`和`unity_4LightAtten0` 等。前向渲染通常会使用这个函数来计算逐顶点光照 |

#### 顶点照明渲染路径(废弃决定)

顶点照明渲染路径是对硬件配置要求最少、运算性能最高，但同时也是得到的效果最差的一种类型，它不支持那些逐像素才能得到的效果，例如阴影、法线映射、高精度的高光反射等。实际上它仅仅是前向渲染路径的一个子集(所有可以在顶点照明渲染路径中实现的功能都可以在前向渲染路径中完成)。

#### 顶点照明渲染路径可访问的内置变量和函数

在 Unity 中，一个顶点照明的 Pass 中最多访问到 8 个逐顶点光源。如果影响该物体的光源数目小于 8, 那么数组中剩下的光源颜色会设置成黑色。

**_顶点照明渲染路径中可以使用的内置变量_**

| 名 称 | 类 型 | 描 述 |
| ---- | ---- | ----- |
| unity_LightColor  | half4[8]  | 光源颜色 |
| unity_LightPosition  | float4[8]  | xyz分量是视角空间中的光源位置。如果光源是平行光，那么 z 分量值为 0，其他光源类型 z 分量值为 1 |
| unity_LightAtten  | half4[8]  | 光源衰减因子。如果光源是聚光灯，x 分量是 `cos(spolAngle/2)`, y 分量是 `1 /cos(spotAngle/4)`，如果是其他类型的光源， x 分量是-1, y 分量是 1。 z 分量是哀减的平方， w 分量是光源范围开根号的结果 |
| unity_SpotDirection  | float4[8] | 如果光源是聚光灯的话，值为视角空间的聚光灯的位置；如果是其他类型的光源，值为 `(0, 0, 1, 0)` |

**_顶点照明渲染路径中可以使用的内置函数_**

| 函数名 | 描述 |
| ----- | --- |
| `float3 ShadeVertexLights (float4 vertex, float3 normal)` | 输入校型空间中的顶点位置和法线，计算四个逐顶点光源的光照以及环境光。内部实现实际上调用了 `ShadeVertex.LightsFull` 函数 |
| `float3 ShadeVertexLightsfull (float4 vertex, float3 normal, int lightCount, bool spotLight)` | 输入模型空间中的顶点位置和法线，计算 lightCount 个光源的光照以及环境光。如果 spotLight 值为 true, 那么这些光源会被当成聚光灯来处理，虽然结果更精确，但计算更加耗时；否则按点光源处理 |

#### 延迟渲染路径

除了前向渲染中使用的颜色缓冲和深度缓冲外，延迟渲染还会利用额外的缓冲区 **G 缓冲 (G-buffer)区**。G 缓冲区存储了我们所关心的表面（通常指的是离摄像机最近的表面）的其他信息，例如该表面的法线、位置、用于光照计算的材质属性等。

默认的 G 缓冲区包含了以下几个渲染纹理 (Render Texture, RT)：

- RTO: 格式是 ARGB32, RGB 通道用于存储漫反射颜色，A 通道没有被使用。
- RTl: 格式是 ARGB32, RGB 通道用于存储高光反射颜色，A 通道用于存储高光反射的指数部分。
- RT2: 格式是 ARGB2101010,RGB 通道用于存储法线，A 通道没有被使用。
- RT3: 格式是 ARGB32 (非 HDR) 或 ARGBHalf (HDR), 用于存储自发光+ lightmap +反射探针 (reflection probes)。
- 深度缓冲和模板缓冲。

延迟渲染主要包含了两个 Pass。在第一个 Pass 中，不进行任何光照计算，仅仅计算哪些片元是可见的并将相关信息存储到 G 缓冲区中，这主要通过深度缓冲技术来实现。在第二个 Pass 中，利用 G 缓冲区的各个片元信息，例如表面法线、视角方向、漫反射系数等，进行真正的光照计算(当在第二个 Pass 中计算光照时，默认情况下**仅可以使用** [Unity 内置的 Standard 光照模型](http://docs.unity3d.com/Manual/RenderTech-DeferredShading.html))。

Unity 有两种延迟渲染路径，一种是**遗留的延迟渲染路径**，即 Unity 5 之前使用的延迟渲染路径。另一种是 Unity5.x 中使用的延迟渲染路径。新旧延迟渲染路径之间的差别很小，只是使用了不同的技术来权衡不同的需求。

延迟渲染路径最适合在场景中光源数目很多、如果使用前向渲染会造成性能瓶颈的情况下使用。而且，延迟渲染路径中的每个光源都可以按逐像素的方式处理。但它有以下**缺点**：

- 不支持真正的抗锯齿 (anti-aliasing) 功能。
- 不能处理半透明物体。
- 对显卡有一定要求，显卡必须支持 MRT (Multiple Render Targets)、Shader Mode 3.0 及以上、深度渲染纹理以及双面的模板缓冲。

**_延迟渲染路径中可以使用的内置变量_**

| 名称 | 类型 | 描述 |
| --- | --- | --- |
| _LightColor | float4 | 光源颜色 |
| _LightMatrix0 | float4x4 | 从世界空间到光源空间的变换矩阵。可用于采样 cookie 和光强衰减纹理 |

#### 4 种渲染路径的比较

[Rendering Paths](http://docs.unity3d.com/Manual/RenderingPaths.html)

### Unity 的光源类型

Unity 共支持 4 种光源类型：**平行光**、**点光源**、**聚光灯**和**面光源 (area light)**。面光源**仅烘焙**时才可发挥作用。最常使用的光源属性有光源的位置、方向（更具体说就是，到某点的方向）、颜色、强度以及衰减（更具体说就是，到某点的衰减，与该点到光源的距离有关）这5个属性。

- 平行光 几何属性只有方向，没有位置和衰减的概念。
- 点光源 由空间中的一个球体定义。点光源可以表示由一个点发出的、向所有方向延伸的光。点光源球心处的光照强度最强，球体边界处的最弱为 0。
- 聚光灯 由空间中的一块锥形区域定义。用于表示由一个特定位置出发、向特定方向延伸的光。聚光灯的衰减也是随着物体逐渐远离点光源而逐渐减小，在锥形的顶点处光照强度最强，在锥形的边界处强度为0。

#### 处理不同的光源类型(前向渲染)

```cs
Shader "Unlit/Chapter9-ForwardRendering"
{
  Properties {
    _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    // 控制高光反射颜色
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    // 控制高光区域的大小
    _Gloss ("Gloss", Range(8.0, 256)) = 20
  }

  SubShader {
    // Base Pass
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma multi_compile_fwdbase
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Diffuse;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 计算漫反射部分
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
        // 计算高光反射部分
        fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
        fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
        // 衰减，平行光没有衰减
        fixed atten = 1.0;

        return fixed4(ambient + (diffuse + specular) * atten, 1.0);
      }
      ENDCG
    }
    // Additional Pass
    Pass {
      Tags { "LightMode"="ForwardAdd" }
      // 如果没有使用 Blend 命令的话，Additional Pass 会直接覆盖掉之前的光照结果。
      Blend One One
      CGPROGRAM
      #pragma multi_compile_fwdadd
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      fixed4 _Diffuse;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 计算漫反射部分
        fixed3 worldNormal = normalize(i.worldNormal);
        // +
        #ifdef USING_DIRECTIONAL_LIGHT
          fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        #else
          fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
        #endif

        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

        fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        fixed3 halfDir = normalize(worldLightDir + viewDir);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
        // +
        #ifdef USING_DIRECTIONAL_LIGHT
          fixed atten = 1.0;
        #else
          float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
          fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
        #endif
        return fixed4((diffuse + specular) * atten, 1.0);
      }
      ENDCG
    }
  }

  Fallback "Specular"
}
```

### Unity 的光照衰减

默认情况下，Unity 使用一张纹理作为查找表来在片元着色器中计算逐像素光照的衰减。**优点：**计算不依赖于数学公式的复杂性，只要使用一个参数值去纹理中采样即可。**缺点：**需要预处理得到采样纹理，纹理的大小也会影响衰减的精度，不方便也不直观。

#### 用于光照衰减的纹理

Unity 在内部使用一张名为 `_LightTexture0` 的纹理来计算光源衰减。如果对该光源使用了 `cookie`，那么衰减查找纹理是 `_LightTextureB0`。`_LightTexture0` **对角线上的纹理颜色值**代表了在光源空间中不同位置的点的衰减值。

为了对 `_LigbtTexture0` 纹理采样得到给定点到该光源的衰减值，我们首先需要得到该点在光源空间中的位置。然后使用这个坐标的模的平方对衰减纹理进行采样，得到衰减值(使用宏 `UNITY_ATTEN_CHANNEL` 来得到衰减纹理中衰减值所在的分量)。

```cs
float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
```

#### 使用数学公式计算衰减

纹理采样的方法可以减少计算衰减时的复杂度，但有时希望可以在代码中利用公式
来计算光源的衰减。可惜的是，Unity **没有**在文档中给出内置衮减计算的相关说明。

### Unity 的阴影

在实时渲染中，最常使用的是名为 `Shadow Map` 的技术。这种技术首先把摄像机的位置放在与光源重合的位置上，那么场景中该光源的阴影区域就是那些摄像机不可视区域。Unity 也是使用这种技术。Unity 使用 `LightMode` 标签被设为 `ShadowCaster` 的 Pass 来专门更新光源的阴影映射纹理(深度纹理)。Unity 首先把摄像机放置到光源的位置上，然后调用该 Pass，通过对顶点变换后得到光源空间下的位置，并据此来输出深度信息到阴影映射纹理中。

- 物体接收来自其他物体的阴影，必须在 Shader 中对阴影映射纹理（包括屏幕空间的阴影图）进行采样，把采样结果和最后的光照结果相乘来产生阴影效果。
- 物体向其他物体投射阴影，必须把该物体加入到光源的阴影映射纹理的计算中，从而让其他物体在对阴影映射纹理采样时可以得到该物体的相关信息。

#### 传统的阴影映射纹理

传统的阴影映射纹理的实现:

- 在正常渲染的 Pass 中把顶点位置变换到光源空间下，得到它在光源空间中的三维位置信息。
- 然后使用 `xy` 分量对阴影映射纹理进行采样，得到阴影映射纹理中该位置的深度信息。
- 如果该深度值小于该顶点的深度值（通常由 `z` 分量得到），那么说明该点位于阴影中。

#### 屏幕空间的阴影映射技术 (Screenspace Shadow Map)

Unity 采用这种技术。屏幕空间的阴影映射原本是**延迟渲染**中产生阴影的方法。
**并不是所有的平台 Unity 都会使用这种技术**，屏幕空间的阴影映射需要显卡支持MRT，而有些移动平台不支持这种特性。

- Unity 首先会通过调用 `"LightMode"="ShadowCaster"` 的 Pass 来得到可投射阴影的光源的阴影映射纹理以及摄像机的深度纹理。
- 然后根据光源的阴影映射纹理和摄像机的深度纹理来得到屏茄空间的阴影图。
- 如果摄像机的深度图中记录的表面深度大于转换到阴影映射纹理中的深度值，就说明该表面虽然是可见的，但是却处于该光源的阴影中。

#### 不透明物体的阴影

- 让物体投射阴影

> 内置 Shader `Normal-VertexLitshader` 内部实现的 `"LightMode"="ShadowCaster"` Pass。实际使用中通常通过 `Fallback` 间接使用

```cs
// Pass to render onject as a shadow caster
Pass {
  Name "ShadowCaster"
  Tags { "LightMode" = "ShadowCaster" }

  CGPROGRAM
  #pragma vertex vert
  #pragma fragment frag
  #pragma multi_compile_shadowcaster
  #include "UnityCG.cginc"

  struct v2f {
    V2F_SHADOW_CASTER;
  }

  v2f vert (appdata_base v)
  {
    v2f o;
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
    return o;
  }

  float4 frag (v2f i) : SV_Target
  {
    SHADOW_CASTER_FRAGMENT(i)
  }
  ENDCG
}
```

- 让物体接收阴影

`SHADOW_COORDS`、`TRANSFER_SHADOW` 和 `SHADOW_ATTENUATION` 是计算阴影时的三剑客。这些宏中会使用上下文变量来进行相关计算，为了能够让这些宏正确工作，我们需要保证自定义的变量名和这些宏中使用的变量名相匹配。我们需要保证：`a2f` 结构体中的顶点坐标变量名必须是 `vertex`，顶点着色器的输出结构体 `v2f` 必须命名为 `v`，且 `v2f`中的项点位置变量必须命名为 `pos`。

```cs
Shader "Unlit/Chapter9-Shadow"
{
  Properties {
    _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    // 控制高光反射颜色
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    // 控制高光区域的大小
    _Gloss ("Gloss", Range(8.0, 256)) = 20
  }

  SubShader {
    // Base Pass
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma multi_compile_fwdbase
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"
      // 计算阴影时所用的宏在这个文件中声明
      #include "AutoLight.cginc"

      fixed4 _Diffuse;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
        // 声明一个用于对阴影纹理采样的坐标
        SHADOW_COORDS(2)
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        // 在顶点着色器中计算上一步中声明的阴影纹理坐标
        TRANSFER_SHADOW(o);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 计算阴影值
        fixed shadow = SHADOW_ATTENUATION(i);
        // 计算漫反射部分
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
        // 计算高光反射部分
        fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
        fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
        // 衰减，平行光没有衰减
        fixed atten = 1.0;
        return fixed4(ambient + (diffuse + specular) * shadow * atten, 1.0);
      }
      ENDCG
    }
    // Additional Pass
    Pass {
      Tags { "LightMode"="ForwardAdd" }
      // 如果没有使用 Blend 命令的话，Additional Pass 会直接覆盖掉之前的光照结果。
      Blend One One
      CGPROGRAM
      #pragma multi_compile_fwdadd
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      fixed4 _Diffuse;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 计算漫反射部分
        fixed3 worldNormal = normalize(i.worldNormal);
        #ifdef USING_DIRECTIONAL_LIGHT
          fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
        #else
          fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
        #endif

        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

        fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        fixed3 halfDir = normalize(worldLightDir + viewDir);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
        // +
        #ifdef USING_DIRECTIONAL_LIGHT
          fixed atten = 1.0;
        #else
          float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
          fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
        #endif
        return fixed4((diffuse + specular) * atten, 1.0);
      }
      ENDCG
    }
  }

  Fallback "Specular"
}

```

- 同一管理光照衰减和阴影

Unity 通过内置的 `UNITY_LIGHT_ATTENUATION` 宏来实现的

#### 透明物体的阴影

对于大多数不透明物体来说， 把 `Fallback` 设为 `VertexLit` 就可以得到正确的阴影。但透明物体的 `Fallback` 设置需要格外小心。

1. **透明度测试**：直接使用 `VertexLit`、`Diffuse`、`Specular` 等作为回调，往往无法得到正确的阴影，因为透明度测试需要在片元着色器中舍弃某些片元，而 `VertexLit` 中的阴影投射纹理并没有进行舍弃的操作。**这种情况需要使用 `Transparent/Cutout/VertexLit` 并提供 `_Cutoff` 属性，然后把物体的 MeshRenderer 组件中的 CastShadows 属性设置为 Two Sided, 强制 Unity 在计算阴影映射纹理时计算所有面的深度信息**
2. **透明度混合**：这种方式实现的半透明物体不会参与深度图和阴影映射纹理的计算，也就是说，它们不会向其他物体投射阴影，也不会接收来自其他物体的阴影。这是由于透明度混合需要关闭深度写入，由此带来的问题也影响了阴影的生成。**这种情况可以通过把 `Fallback` 设置为 `VertexLit`、`Diffuse` 这些不透明物体使用的 Shader，然后设置物体的 Mesh Renderer 组件上的 Cast Shadows 和 Receive Shadows 选项来控制是否需要向其他物体投射或接收阴影(这种实现效果其实不太正确)**

## 基础纹理

!!这里实现的 Shader 往往并不能直接应用到实际项目中!!

### 单张纹理

#### 纹理的属性

![TextureImporter](https://docs.unity3d.com/Manual/class-TextureImporter.html)

#### 单张纹理代替物体的漫反射颜色

通常会使用一张纹理来代替物体的漫反射颜色

```cs
// 使用 Blinn-Phong 光照模型来计算光照
Shader "Unity Shaders Book/Chapter 7/Single Texture" {
  Properties {
    _Color ("Color Tint", Color) = (1, 1, 1, 1)
    _MainTex ("Main Tex", 2D) = "white" {}
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    _Gloss ("Gloss", Range(8.0, 26)) = 20
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Color;
      sampler2D _MainTex;
      // 在Unity 中，我们需要使用 `纹理名_ST` 的方式来声明某个纹理的属性。
      // ST 是缩放(scale) 和平移(translation) 的缩写。
      // _MainTex_ST.xy 存储的是缩放值，_MainTex_ST.zw 存储的是偏移值。
      float4 _MainTex_ST;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        // 将模型的第一组纹理坐标存储到该变量中
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
        // 存储纹理坐标以便在片元着色器中使用该坐标进行纹理采样
        float2 uv : TEXCOORD2;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        // o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldPos = UnityObjectToWorldDir(v.vertex);
        o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
        // o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

        // 使用纹理进行采样
        fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
        fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        fixed3 halfDir = normalize(worldLightDir + viewDir);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
        return fixed4(ambient + diffuse + specular, 1.0);
      }

      ENDCG
    }
  }

  FallBack "Specular"
}
```

### 凹凸映射

凹凸映射的目的是使用一张纹理来修改模型表面的法线，以便为模型提供更多的细节。这种方法不会真的改变模型的顶点位置。

有两种主要的方法可以用来进行凹凸映射：一种方法是使用一张**高度纹理(height map)**来模拟**表面位移(displacement)**,然后得到一个修改后的法线值，这种方法也被称为**高度映射(height mapping)**; 另一种方法则是使用一张**法线纹理(normal map)**来直接存储表面法线，这种方法又被称为**法线映射(normal mapping)**。

#### 高度纹理

高度图中存储的是**强度值(intensity)**,它用于表示模型表面局部的海拔高度。因此，颜色越浅表明该位置的表面越向外凸起，而颜色越深表明该位置越向里凹。高度图通常会和法线映射一起使用，用于给出表面凹凸的额外信息。

- 优点：非常直观，可以从高度图中明确地知道一个模型表面的凹凸情况
- 缺点：计算更加复杂，在实时计算时不能直接得到表面法线，而是需要由像素的灰度值计算而得，因此需要消耗更多的性能。

#### 法线纹理

法线纹理中存储的是表面的法线方向。我们在Shader中对法线纹理进行纹理采样后，还需要对结果进行一次反映射的过程，以得到原先的法线方向 `normal = pixel x 2 - 1`。(这是由于法线方向的分量范围在 `[-1, 1]`, 而像素的分量范围为 `[0, 1]`, 通常使用映射 `pixel = (normal + 1)/2` 进行处理。

##### 模型空间的法线纹理(object-space normal map)

将修改后的模型空间中的表面法线存储在一张纹理中。

**优点**：

- 实现简单，更加直观。不需要模型原始的法线和切线等信息，计算更少。
- 在纹理坐标的缝合处和尖锐的边角部分，可见的突变（缝隙）较少，即可以提供平滑的边界。

##### 切线空间的法线纹理(tangent-space normal map)

切线空间的原点就是该顶点本身，z 轴是顶点的法线方向，x 轴是顶点的切线方向，y 轴可由法线和切线叉积而得。**切线空间在很多情况下都优于模型空间**。

![模型顶点的切线空间](http://static.zybuluo.com/candycat/fpgdxhkx2vrfag4wpxkubh08/tangent_space.png)

**优点**：

- 自由度很高。模型空间下的法线纹理记录的是绝对法线信息，仅可用于创建它时的那个模型，不能应用到其他模型上。而切线空间下的法线纹理记录的是相对法线信息，这意味着，即便把该纹理应用到一个完全不同的网格上，也可以得到一个合理的结果。
- 可进行 UV 动画。这种 UV 动画在水或者火山熔岩这种类型的物体上会经常用到。
- 可以重用法线纹理。
- 可压缩。由于切线空间下的法线纹理中法线的 Z 方向总是正方向，因此我们可以仅存储 XY 方向，而推导得到 Z 方向。而模型空间下的法线纹理由于每个方向都是可能的，因此必须存储 3 个方向的值，不可压缩。

计算光照模型是坐标转换有两种思路，从效率上方法1优于方法2，但从通用性上方法2优于方法1。

##### 切线空间下的法线纹理

在切线空间下进行光照计算，把光照方向、视角方向变换到切线空间下；

基本思路是：在片元着色器中通过纹理采样得到切线空间下的法线，然后再与切线空间下的视角方向、光照方向等进行计算，得到最终的光照结果。

```cs
  Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
    Properties {
      _Color ("Color Tint", Color) = (1,1,1,1)
      _MainTex ("Main Tex", 2D) = "white" {}
      // 法线纹理，"bump" 是 Unity 内置的法线纹理，当没有提供任何法线纹理时，"bump"就对应了模型自带的法线信息。
      _BumpMap ("Normal Map", 2D) = "bump" {}
      // _BumpScale 是用于控制凹凸程度的，当它为0时，意味着该法线纹理不会对光照产生任何影响。
      _BumpScale ("Bump Scale", Float) = 1.0
      _Specular ("Specular", Color) = (1,1,1,1)
      _Gloss ("Gloass", Range(8.0, 256)) = 20
    }

    SubShader {
      Pass {
        Tags { "LightMode" = "ForwardBase" }

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag

        #include "Lighting.cginc"

        fixed4 _Color;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _BumpMap;
        float4 _BumpMap_ST;
        float _BumpScale;
        fixed4 _Specular;
        float _Gloss;

        struct a2v {
          float4 vertex : POSITION;
          float3 normal : NORMAL;
          // TANGENT 语义来描述 float4 类型的 tangent 变量，以告诉 Unity 把顶点的切线方向填充到tangent 变量中。
          // tangent.w 分量用来决定切线空间中的第三个坐标轴一副切线的方向性
          float4 tangent : TANGENT;
          float4 texcoord : TEXCOORD0;
        };

        struct v2f {
          float4 pos : SV_POSITION;
          float4 uv : TEXCOORD0;
          float3 lightDir : TEXCOORD1;
          float3 viewDir : TEXCOORD2;
        };

        v2f vert(a2v v) {
          v2f o;

          o.pos = UnityObjectToClipPos(v.vertex);
          // xy 分量存储 _MainTex 的纹理坐标
          o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
          // zw 分量存储 _BumpMap 的纹理坐标
          o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

          TANGENT_SPACE_ROTATION;

          o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
          o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

          return o;
        }

        fixed4 frag(v2f i) : SV_Target {
          fixed3 tangentLightDir = normalize(i.lightDir);
          fixed3 tangentViewDir = normalize(i.viewDir);

          // 对法线纹理_BumpMap 进行采样
          fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
          fixed3 tangentNormal;
          // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
          // tangentNormal.z = sqrt (1.0 - saturate (dot (tangentNormal.xy, tangentNormal.xy))) ;
          tangentNormal = UnpackNormal(packedNormal); // 使用 Unity 的内置函数 UnpackNonnal 来得到正确的法线方向
          tangentNormal.xy *= _BumpScale;
          tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
          fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
          fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
          fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
          fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
          fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
          return fixed4(ambient + diffuse + specular, 1.0);
        }

        ENDCG
      }
    }

    Fallback "Specular"
  }
  ```

##### 世界空间下的法线纹理

在世界空间下进行光照计算，把采样得到的法线方向变换到世界空间下，再和世界空间下的光照方向和视角方向进行计算。

基本思想是：在顶点着色器中计算从**切线空间到世界空间**的变换矩阵，并把它传递给片元着色器。变换矩阵的计算可以由顶点的切线、副切线和法线在世界空间下的表示来得到。最后，我们只需要在片元着色器中把法线纹理中的法线方向从切线空间变换到世界空间下即可(尽管这种方法需要更多的计算，但在需要使用 Cubemap 进行环境映射等情况下，我们就需要使用这种方法)。

```cs
Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
  Properties {
    _Color ("Color Tint", Color) = (1,1,1,1)
    _MainTex ("Main Tex", 2D) = "white" {}
    // 法线纹理，"bump" 是 Unity 内置的法线纹理，当没有提供任何法线纹理时，"bump"就对应了模型自带的法线信息。
    _BumpMap ("Normal Map", 2D) = "bump" {}
    // _BumpScale 是用于控制凹凸程度的，当它为0时，意味着该法线纹理不会对光照产生任何影响。
    _BumpScale ("Bump Scale", Float) = 1.0
    _Specular ("Specular", Color) = (1,1,1,1)
    _Gloss ("Gloass", Range(8.0, 256)) = 20
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM

      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Color;
      sampler2D _MainTex;
      float4 _MainTex_ST;
      sampler2D _BumpMap;
      float4 _BumpMap_ST;
      float _BumpScale;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        // TANGENT 语义来描述 float4 类型的 tangent 变量，以告诉 Unity 把顶点的切线方向填充到 tangent 变量中。
        // tangent.w 分量用来决定切线空间中的第三个坐标轴一副切线的方向性
        float4 tangent : TANGENT;
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float4 uv : TEXCOORD0;
        // 存储从切线空间到世界空间的变换矩阵的每一行
        float4 TtoW0 : TEXCOORD1;
        float4 TtoW1 : TEXCOORD2;
        float4 TtoW2 : TEXCOORD3;
      };

      v2f vert(a2v v) {
        v2f o;

        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
        o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        float3 worldNormal = UnityObjectToWorldNormal(v.normal);
        float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

        o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
        o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
        o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

        float3 tangentLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
        float3 tangentViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

        // 对法线纹理_BumpMap 进行采样
        fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
        fixed3 tangentNormal;
        // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
        // tangentNormal.z = sqrt (1.0 - saturate (dot (tangentNormal.xy, tangentNormal.xy))) ;
        tangentNormal = UnpackNormal(packedNormal); // 使用 Unity 的内置函数 UnpackNonnal 来得到正确的法线方向
        tangentNormal.xy *= _BumpScale;
        tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
        // + 把法线变换到世界空间下
        tangentNormal = normalize(half3(dot(i.TtoW0.xyz, tangentNormal), dot(i.TtoW1.xyz, tangentNormal), dot(i.TtoW2.xyz, tangentNormal)));

        fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
        fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
        fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
        return fixed4(ambient + diffuse + specular, 1.0);
      }

      ENDCG
    }
  }

  Fallback "Specular"
}
```

### 渐变纹理

这种技术最初由 Gooch 等人(Valve 公司)在 1998 年他们发表的一篇著名的论文《A Non-Photorealistic Lighting Model For Automatic Technical Illustration》中被提出，在这篇论文中，作者提出了一种基  于冷到暖色调(cool-to-warm tones)的着色技术，用来得到一种插画风格的渲染效果。渐变纹理常用来控制漫反射光照。

```cs
Shader "Unity Shader Book/Chapter 6/Ramp Texture"
{
  Properties {
    _Color ("Color Tint", Color) = (1, 1, 1, 1)
    _RampTex ("Ramp Tex", 2D) = "white" {}
    _Specular ("Specular", Color) = (1, 1, 1, 1)
    _Gloss ("Gloss", Range(8.0, 256)) = 20
  }

  SubShader {
    Pass {
      Tags { "LightMode"="ForwardBase" }
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"

      fixed4 _Color;
      sampler2D _RampTex;
      float4 _RampTex_ST;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
        float2 uv : TEXCOORD2;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        // 使用半兰伯特模型纹理采样
        fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
        fixed3 diffuseColor = te x2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;

        fixed3 diffuse = _LightColor0.rgb * diffuseColor;

        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
        fixed3 halfDir = normalize(worldLightDir + viewDir);
        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
        return fixed4(ambient + diffuse +specular, 1.0);
      }

      ENDCG
    }
  }

  Fallback "Specular"
}
```

### 遮罩纹理(mask texture)

使用遮罩纹理的流程一般是：通过采样得到遮罩纹理的纹素值，然后使用其中某个（或某几个）通道的值（例如 texel.r) 来与某种表面属性进行相乘，这样，当该通道的值为 0 时，可以保护表面不受该屈性的影响。**使用遮罩纹理可以让美术人员更加精准（像素级别）地控制模型表面的各种性质**

通常，我们会充分利用一张纹理的RGBA四个通道，用于存储不同的属性。例如，我们可以把高光反射的强度存储在 R 通道，把边缘光照的强度存储在 G 通道，把高光反射的指数部分存储在 B 通道，最后把自发光强度存储在A通道。

```cs
Shader "Unity Shaders Book/Chapter 7/Mask Texture" {
  Properties {
    _Color ("Color Tint", Color) = (1,1,1,1)
    _MainTex ("Main Tex", 2D) = "white" {}
    _BumpMap ("Bump Map", 2D) = "bump" {}
    _BumpScale ("Bump Scale", Float) = 1.0
    // 高光反射遮罩纹理
    _SpecularMask ("Specular Mask", 2D) = "white" {}
    // 控制遮罩影响度的系数
    _SpecularScale ("Specular Scale", Float) = 1.0
    _Specular ("Specular", Color) = (1,1,1,1)
    _Gloss ("Gloss", Range(8.0, 256)) = 20
  }

  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "Lighting.cginc"

      fixed4 _Color;
      sampler2D _MainTex;
      // 为主纹理_MainTex、法线纹理_BwnpMap 和遮罩纹理_SpecularMask 定义了
      // 它们共同使用的纹理属性变盐_MainTex_ST。这意味着，在材质面板中修改主纹
      // 理的平铺系数和偏移系数会同时影响 3 个纹理的采样。使用这种方式可以让我们
      // 节省需要存储的纹理坐标数目
      float4 _MainTex_ST;
      sampler2D _BumpMap;
      float _BumpScale;
      sampler2D _SpecularMask;
      float _SpecularScale;
      fixed4 _Specular;
      float _Gloss;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 lightDir : TEXCOORD1;
        float3 viewDir : TEXCOORD2;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv.xy = v.texcoord.xy * _MainTex_ST.xy  + _MainTex_ST.zw;

        TANGENT_SPACE_ROTATION;

        o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
        o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 tangentLightDir = normalize(i.lightDir);
        fixed3 tangentViewDir = normalize(i.viewDir);

        fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
        tangentNormal.xy *= _BumpScale;
        tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

        fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

        fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

        fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
        fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;

        fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss) * specularMask;
        return fixed4(ambient + diffuse + specular, 1.0);
      }

      ENDCG
    }
  }
  Fallback "Specular"
}
```

## 高级纹理

### 立方体纹理

在图形学中，**立方体纹理(Cubemap)**是**环境映射(Environment Mapping)**的一种方法。环境映射可以模拟物体周围的环境，使用了环境映射的物体可以看起来像镀了层金属一样反射出周围的环境。立方体纹理一共包含了**6 张图像**，对应立方体的 6 个面。

使用立方体纹理的**优点**在于，它的实现简单快速，而且得到的效果也比较好。但它也有一些**缺点**，例如当场景中引入新的物体、光源，或者物体发生移动时，就需要重新生成立方体纹理。立方体纹理也仅可以反射环境，但不能反射使用了该立方体纹理的物体本身(立方体纹理不能模拟多次反射的结果，所以尽量对凸面体而不要对凹面体使用立方体纹理)。

立方体纹理在实时渲染中有很多应用，最常见的是用于**天空盒子(Skybox)**以及**环境映射**。

#### 用于环境映射的立方体纹理

通过这种方法，可以模拟出金属质感的材质。创建用于环境映射的立方体纹理有三种方法：

- 直接有一些特殊布局的纹理创建（需要提供一张具有特殊布局的纹理，把该纹理的 Texture Type 设置为 Cubemap 即可，**官方推荐**这种做法，它可以对纹理数据进行压缩，同时支持边缘修正、光滑反射和 HDR 等功能）
- 手动创建一个 Cubemap 资源，再赋予 6 张图给它
- 脚本生成（通过利用 Unity 提供的 `Camera.RenderToCubemap` 函数来实现，这个函数可以把从任意位置观察到的场景图片存储到 6 张图像中，从而创建出该位置上的立方体纹理）关键代码如下：

```cs
void OnWizardCreate() {
  // create temporary camera for rendering
  GameObject go = new GameObject("CubemapCamera");
  go.AddComponent<Camera>();
  // place it on the object
  go.transform.position = renderFromPosition.position;
  // render into cubemap
  go.GetComponent<Camera>().RenderToCubemap(cubemap);
  // destroy temporary camera
  DestroyImmdiate(go);
}
```

#### 反射

使用了反射效果的物体通常看起来就像镀了层金属。模拟反射只需要通过入射光线的方向和表面法线方向来计算反射方向，再利用反射方向对立方体纹理采样即可。

```cs
Shader "Unlit/Chapter10-Reflection"
{
  Properties {
    _Color ("Color Tint", Color) = (1,1,1,1)
    // 控制反射颜色
    _ReflectColor ("Reflection Color", Color) = (1,1,1,1)
    // 控制反射程度
    _ReflectAmount ("Reflect Amount", Range(0,1)) = 1
    // 模拟反射的环境映射纹理
    _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
  }

  SubShader {
    Tags { "RenderType"="Opaque" "Queue"="Geometry"}
    Pass {
      Tags { "LightMode" = "ForwardBase" }
      CGPROGRAM
      #pragma multi_compile_fwdbase
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      fixed4 _Color;
      fixed4 _ReflectColor;
      fixed _ReflectAmount;
      samplerCUBE _Cubemap;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      }

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        fixed3 worldNormal : TEXCOORD1;
        fixed3 worldViewDir : TEXCOORD2;
        fixed3 worldRefl : TEXCOORD3;
        SHADOW_COORDS(4)
      }

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
        // Compute the reflect dir in world space
        // 计算视角方向关于顶点法线的反射方向来求得入射光线的方向
        // 也可以选择在片元着色器中计算，这样得到的效果更加细腻
        o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
        TRANSFER_SHADOW(o);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(i.worldLightDir);
        fixed3 worldViewDir = normalize(i.worldViewDir);

        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(i.worldNormal, i.worldLightDir));
        // Use the reflect dir in world space to access the cubemap
        // 利用反射方向来对立方体纹理采样
        fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor;

        UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

        // Mix the diffuse color with the reflected color
        fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
        return fixed4(color, 1.0);
      }
      ENDCG
    }
  }

  FallBack "Reflective/VertexLit"
}
```

#### 折射

当给定入射角时，我们可以使用斯涅尔定律 (Snell's Law) 来计算折射射角。

```cs
// η1、η2 为两种介质的折射率
// θ1、θ2 为入射光线和折射光线与法线的夹角
η1 * sinθ1 = η2 * sinθ2
```

严格来讲，更准确的模拟方法需要计算两次折射(从外到内和从来内到外各一次)，但想要在实时渲染中模拟出第二次折射方向比较复杂，因此，在实时渲染中我们通常仅模拟第一次折射。实际的视觉效果也比较可靠。

```cs
Shader "Unlit/Chapter10-Refraction"
{
  Properties {
    _Color ("Color Tint", Color) = (1,1,1,1)
    _RefractColor ("Refraction Color", Color) = (1,1,1,1)
    _RefractAmount ("Refraction Amount", Range(0,1)) = 1
    _RefractRatio ("Refraction Ratio", Range(0.1,1)) = 0.5
    _Cubemap ("Refraction Cubmap", Cube) = "Skybox" {}
  }

  SubShader {
    Tags { "RenderType"="Opaque" "Queue"="Geometry" }
    Pass {
      Tags { "LightMode"="ForwardBase" }

      CGPROGRAM
      #pragma multi_compile_fwdbase
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      fixed4 _Color;
      fixed4 _RefractColor;
      float _RefractAmount;
      fixed _RefractRatio;
      samplerCUBE _Cubemap;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        fixed3 worldNormal : TEXCOORD1;
        fixed3 worldViewDir : TEXCOORD2;
        fixed3 worldRefr : TEXCOORD3;
        SHADOW_COORDS(4)
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
        // Compute the refract dir in world space
        // refract 函数用来计算折射方向。
        // 第一个参数即为入射光线的归一化方向，
        // 第二个参数是归一化表面法线，
        // 第三个参数是入射光线所在介质的折射率和折射光线所在介质的折射率之间的比值
        o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);

        TRANSFER_SHADOW(o);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        fixed3 worldViewDir = normalize(i.worldViewDir);

        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

        fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));

        // Use the refract dir in world space to access the cubemap
        // 使用折射方向对立方体纹理进行采样
        // 没有对 i.worldRefr 进行归一化操作，因为对立方体纹理的采样只需要提供方向
        fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractColor.rgb;

        UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

        // Mix the diffuse color with refract color
        fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) * atten;
        return fixed4(color, 1.0);
      }

      ENDCG
    }
  }
  FallBack "Reflective/VertexLit"
}

```

#### 菲涅耳反射

**菲涅耳反射(Fresnelreflection)**描述了一种光学现象，即当光线照射到物体表面上时，一部分发生反射，一部分进入物体内部，发生折射或散射。被反射的光和入射光之间存在一定的比率关系，这个比率关系可以通过菲涅耳等式进行计算。经常会使用菲涅耳反射来根据视角方向控制反射程度。由于菲涅尔反射的计算非常复杂，通常会采用近似公式计算：

**_Schlick菲涅耳近似等式_**

```cs
// F0 反射系数，用于控制菲涅耳反射的强度
// v 是视角方向，n 是表面法线
F[schlick(v,n)] = F0 + (1 - F0)(1 - v·n)^5
```

```cs
Shader "Unlit/Chapter10-Fresnel"
{
  Properties {
    _Color ("Color Tint", Color) = (1,1,1,1)
    _FresnelScale ("Frenel Scale", Range(0,1)) = 0.5
    _Cubemap ("Reflection Cubemap", Cube) = "Skybox" {}
  }

  SubShader {
    Tags { "RenderType"="Opaque" "Queue"="Geometry" }

    Pass {
      Tags { "LightMode"="ForwardBase" }

      CGPROGRAM
      #pragma multi_compile_fwdbase
      #pragma vertex vert
      #pragma fragment frag

      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      fixed4 _Color;
      fixed _FresnelScale;
      samplerCUBE _Cubemap;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };
      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        fixed3 worldNormal : TEXCOORD1;
        fixed3 worldViewDir : TEXCOORD2;
        fixed3 worldRefl : TEXCOORD3;
        SHADOW_COORDS(4)
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
        o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
        TRANSFER_SHADOW(o);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        fixed3 worldViewDir = normalize(i.worldViewDir);

        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

        UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

        fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;

        fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

        fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));

        fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;

        return fixed4(color, 1.0);
      }
      ENDCG
    }
  }
  Fallback "Reflective/VertexLit"
}
```

**_Empricial菲涅耳近似等式_**

```cs
// bias、scale、power 是控制项
F[Empricial(v,n)] = max(0, min(1, bias + scale x (1 - v·n)^power))
```

### 渲染纹理

现代的 GPU 允许我们把整个三维场景渲染到一个中间缓冲中，即**渲染目标纹理(Render Target Texture, RTT)**，而不是传统的帧缓冲或后备缓冲(back buffer)。与之相关的是**多重渲染目标(Multiple Render Target, MRT)**，这种技术指的是GPU允许我们把场景同时渲染到多个渲染目标纹理中，而不再需要为每个渲染目标纹理单独渲染完整的场景。延迟渲染就是使用多重渲染目标的一个应用。Unity 为渲染目标纹理定义了一种专门的纹理类型 —— **渲染纹理(Render Texture)**。

**_在 Unity 中使用渲染纹理通常有两种方式：_**

1. 在Project 目录下创建一个渲染纹理，然后把某个摄像机的渲染目标设置成该渲染纹理，这样一来该摄像机的渲染结果就会实时更新到渲染纹理中，而不会显示在屏幕上(这种方式可以选择渲染纹理的分辨率、滤波模式等纹理属性)。
2. 在屏幕后处理时使用 `GrabPass` 命令或 `OnRenderlmage` 函数来获取当前屏幕图像，Unity 会把这个屏幕图像放到一张和屏幕分辨率等同的渲染纹理中，然后可以在自定义的 Pass 中把它们当成普通的纹理来处理，从而实现各种屏幕特效。

#### 镜子效果

1. 创建一个摄像机(Camera)，并调整它的位置、裁剪平面、视角等，使得它的显示图像是我们希望的镜子图像。
2. 创建一个渲染纹理(Render Texture)并赋予 Camera 的 Target Texture
3. 创建一个材质 Material 和一个 Shader(代码如下)，并将 Shader 赋给 Material
4. 创建一个四边形 Quad 并赋予其 Material

```cs
Shader "Unlit/Chapter10-Mirror"
{
  Properties {
    _MainTex ("Main Tex", 2D) = "white" {}
  }
  SubShader {
    Tags { "RenderType"="Opaque" "Queue"="Geometry"}

    Pass {
      CGPROGRAM

      #pragma vertex vert
      #pragma fragment frag

      sampler2D _MainTex;

      struct a2v {
        float4 vertex : POSITION;
        float3 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);

        o.uv = v.texcoord;
        // Mirror needs to filp x
        o.uv.x = 1 - o.uv.x;

        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        return tex2D(_MainTex, i.uv);
      }

      ENDCG
    }
  }
   FallBack Off
}
```

#### 玻璃效果

通常会使用 **GrabPass** 来实现诸如玻璃等透明材质的模拟，与使用简单的透明混合不同，使用 GrabPass 可以让我们对该物体后面的图像进行更复杂的处理，例如使用法线来模拟折射效果，而不再是简单的和原屏幕颜色进行混合。在 Shader 中定义了一个 GrabPass 后，Unity 会把当前屏幕的图像绘制在一张纹理中，以便我们在后续的 Pass 中访问它。

!! 使用 GrabPass 时往往需要把物体的渲染队列设置成透明队列（即`"Queue"="Transparent"`)，这样才可以保证当渲染该物体时，所有的不透明物体都已经被绘制在屏幕上，从而获取正确的屏幕图像。

1. 使用一张法线纹理来修改模型的法线信息
2. 通过一个 Cubemap 来模拟玻璃的**反射**
3. 使用 GrabPass 获取玻璃后面的屏幕图像，并使用切线空间下的法线对屏幕纹理坐标偏移后，再对屏幕图像进行采样来模拟近似的**折射**

```cs
Shader "Unlit/Chapter10-GlassRefraction"
{
  Properties
  {
    _MainTex ("Main Tex", 2D) = "white" {}
    _BumpMap ("Normal Map", 2D) = "bump" {}
    _Cubemap ("Enviroment CubeMap", Cube) = "_Skybox" {}
    _Distortion ("Distortion", Range(0,100)) = 10
    _RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
  }
  SubShader
  {
    // Queue设置成 Transparent 可以确保该物体渲染时，
    // 其他所有不透明物体都已经被渲染到屏幕上了，否则就可能无法正确得到 “透过玻璃看到的图像“。
    // 设置 RenderType 则是为了在使用着色器替换 (Shader Replacement) 时，
    // 该物体可以在需要时被正确渲染。
    Tags { "Queue"="Transparent" "RenderType"="Opaque" }

    // "_RefractionTex" 字符串内部的名称决定了抓取得到的屏幕图像将会被存入哪个纹理中
    // 可以省略声明该字符串，但直接声明纹理名称的方法往往可以得到更高的性能
    GrabPass { "_RefractionTex" }

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 texcoord: TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float4 scrPos : TEXCOORD0;
        float4 uv : TEXCOORD1;
        float4 TtoW0 : TEXCOORD2;  
          float4 TtoW1 : TEXCOORD3;  
          float4 TtoW2 : TEXCOORD4;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;
      sampler2D _BumpMap;
      float4 _BumpMap_ST;
      samplerCUBE _Cubemap;
      float _Distortion;
      fixed _RefractAmount;
      // _RefractionTex 和 _RefractionTex_TexelSize 对应了在使用 GrabPass 时指定的纹理名称
      sampler2D _RefractionTex;
      // _RefractionTex_TexelSize 可以让我们得到该纹理的纹素大小
      float4 _RefractionTex_TexelSize;
      v2f vert (a2v v)
      {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        // ComputeGrabScreenPos 函数用来得到对应被抓取的屏幕图像的采样坐标
        o.scrPos = ComputeGrabScreenPos(o.pos);
        o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
        o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
        fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        // 把法线方向从切线空间（由法线纹理采样得到）变换到世界空间下
        fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

        o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
        o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
        o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

        return o;
      }
      fixed4 frag (v2f i) : SV_Target
      {
        float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
        fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

        // Get the normal in tangent space
        fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));  

        // Compute the offset in tangent space
        // 对屏幕图像的采样坐标进行偏移，模拟折射效果
        float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
        i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
        // 对 scrPos 透视除法得到真正的屏幕坐标
        // 并使用该坐标对抓取的屏幕图像 _RefractionTex 进行采样，得到模拟的折射颜色。
        fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;

        // Convert the normal to world space
        bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
        fixed3 reflDir = reflect(-worldViewDir, bump);
        fixed4 texColor = tex2D(_MainTex, i.uv.xy);
        // 使用反射方向对 Cubemap 进行采样，并把结果和主纹理颜色相乘后得到反射颜色。
        fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

        fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

        return fixed4(finalColor, 1);
      }
      ENDCG
    }
  }
  Fallback "Diffuse"
}

```

#### 渲染纹理与 GrabPass 比较

GrabPass 和渲染纹理+额外摄像机的方式都可以抓取屏幕图像。GrabPass 的好处在于实现简单。从效率上来讲，使用渲染纹理的效率往往要好于 GrabPass, 尤其在移动设备上。

使用渲染纹理我们可以自定义渲染纹理的大小，尽管这种方法需要把部分场景再次渲染 遍，但我们可以通过调整摄像机的渲染层来减少二次渲染时的场景大小，或使用其他方法来控制摄像机是否需要开启。而使用 GrabPass 获取到的图像分辨率和显示屏幕是一致的，这意味着在某些高分辨率的设备上可能会造成严重的带宽影响。在移动设备上，GrabPass 虽然不会重新渲染场景，但它往往需要 CPU 直接读取后备缓冲 (back buffer) 中的数据，破坏了 CPU 和 GPU 之间的并行性，比较耗时，甚至在些移动设备上不支持。

### 程序纹理

**程序纹理(Procedural Texture)**指的是那些由计算机生成的图像，我们通常使用一些特定的算法来创建个性化图案或非常真实的自然元素，例如木头、石子等。使用程序纹理的好处在于我们可以使用各种参数来控制纹理的外观，而这些属性不仅仅是那些颜色属性，甚至可以是完全不同类型的图案属性，这使得我们可以得到更加丰富的动画和视觉效果。

#### Unity的程序材质

程序材质和它使用的程序纹理并不是在Unity中创建的，而是使用一个名为 `Substance Designer` 的软件在 Unity 外部创建的以 `.sbsar` 为后缀的文件。

## 透明效果

在 Unity 中，通常使用两种方法来实现透明效果：第一种是使用**透明度测试(Alpha Test)**，这种方法其实**无法真正得到**半透明效果；另一种是**透明度混合(Alpha Blending)**。

- 深度缓冲

在实时渲染中，深度缓冲用于解决可见性(visibility)问题，它可以决定哪个物体的哪些部分会被渲染在前面，而哪些部分会被其他物体遮挡。它的**基本思想**是根据深度缓存中的值来判断该片元距离摄像机的距离，当渲染一个片元时，需要把它的深度值和已经存在于深度缓冲中的值进行比较（如果开启了深度测试），如果它的值距离摄像机更远，那么说明这个片元不应该被渲染到屏幕上（有物体挡住了它）；否则，这个片元应该覆盖掉此时颜色缓冲中的像素值，并把它的深度值更新到深度缓冲中（如果开启了深度写入）。

当使用透明度混合时，深度写入(CZWrite)是关闭的。

### 透明度测试

只要一个片元的透明度不满足条件（通常是小于某个阈值），那么它对应的片元就会被舍弃。透明度测试**不需要关闭深度写入**，它和其他不透明物体最大的不同就是它会根据透明度来舍弃一些片元。它产生的效果很极端，要么完全透明，即看不到，要么完全不透明。而且得到的透明效果在边缘处往往参差不齐有锯齿，这是因为在边界处纹理的透明度的变化精度问题。

通常会在片元着色器中使用 `clip` 函数来进行透明度测试。

```cs
void clip(float4 x)
{
  // 如果给定参数的任何一个分量是负数，就会舍弃当前像素的输出颜色
  if(any(x < 0))
    discard;
}
```

```cs
Shader "Unity Shaders Book/Chapter 8/AlphaTest"
{
  Properties {
    _Color ("Main Tint", Color) = (1,1,1,1)
    _MainTex ("Main Tex", 2D) = "white" {}
    // 决定调用 clip 进行透明度测试时使用的判断阈值
    _CutOff ("Alpha Cut Off", Range(0,1)) = 0.5
  }
  SubShader {
    Tags { "Quene"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }
    Pass {
      Tags { "LightMode"="ForwardBase" }
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "Lighting.cginc"

      fixed4 _Color;
      sampler2D _MainTex;
      float4 _MainTex_ST;
      fixed _CutOff;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
        float2 uv : TEXCOORD2;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        fixed4 texColor = tex2D(_MainTex, i.uv);

        clip(texColor.a - _CutOff);

        fixed3 albedo = texColor.rgb * _Color.rgb;
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
        fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
        return fixed4(ambient + diffuse, 1.0);
      }

      ENDCG
    }
  }
  Fallback "Transparent/Cutout/VertexLit"
}
```

### 透明度混合

使用当前片元的透明度作为混合因子，与已经存储在颜色缓冲中的颜色值进行混合，得到新的颜色。但是，透明度混合**需要关闭深度写入**（深度缓冲只读），这使得我们要非常小心物体的渲染顺序(当模型本身有复杂的遮挡关系或是包含了复杂的非凸网格的时候，就会有各种各样因为排序错误而产生的错误的透明效果)。

为了进行混合，我们需要使用 Unity 提供的混合命令 Blend。

**_Shaderlab的Blend命令_**

| 语义 | 描述 |
| --- | --- |
| Blend Off | 关闭混合 |
| Blend SrcFactor DstFactor | 开启混合，并设置混合因子。源颜色（该片元产生的颜色）会乘以 SrcFactor, 而目标颜色（已经存在于颜色缓存的颜色）会乘以 DstFactor, 然后把两者相加后再存入颜色缓冲中 |
| Blend SrcFactor DstFactor, SrcFactorA DstFactorA | 与上面的几乎一致，只是使用不同的因子来混合透明通道 |
| BlendOp BleodOperation | 并非是把源颜色和目标颜色简单相加后混合， 而是使用 BlendOperation 对它们进行其他操作 |

```cs
Shader "Unity Shaders Book/Chapter 8/AlphaBlend"
{
  Properties {
    _Color ("Main Tint", Color) = (1,1,1,1)
    _MainTex ("Main Tex", 2D) = "white" {}
    // 用于在透明纹理的基础上控制整体的透明度
    _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
  }
  SubShader {
    // Quene 指定为 Transparent
    // "IgnoreProjector"="True" 这意味着这个 Shader 不会受到投影器 (Projectors) 的影响
    // RenderType 标签可以让 Unity 把这个 Shader归入到提前定义的组（这里就是 Transparent 组）中，用来指明该 Shader 是一个使用了透明度混合的 Shader。
    Tags { "Quene"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    Pass {
      Tags { "LightMode"="ForwardBase" }
      // 关闭深度写入
      ZWrite Off
      // 开启设置混合模式
      // 将源颜色（该片元着色器产生的颜 色）的混合因子设为SrcAlpha,把目标颜色（已经存在于颜色缓冲中的颜色）的混合因子设为OneMinusSrcAlpha
      Blend SrcAlpha OneMinusSrcAlpha

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "Lighting.cginc"

      fixed4 _Color;
      sampler2D _MainTex;
      float4 _MainTex_ST;
      fixed _AlphaScale;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float3 worldNormal : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
        float2 uv : TEXCOORD2;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        fixed4 texColor = tex2D(_MainTex, i.uv);
        fixed3 albedo = texColor.rgb * _Color.rgb;
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
        fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
        // 设置透明通道
        return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
      }

      ENDCG
    }
  }
  Fallback "Transparent/VertexLit"
}
```

### Unity Shader 的渲染顺序

Unity 为了解决渲染顺序的问题提供了**渲染队列 (render queue)**这一解决方案。使用 SubShader 的 Queue 标签来决定我们的模型将归于哪个渲染队列。Unity在内部使用一系列整数索引来表示每个渲染队列，且索引号越小表示越早被渲染。

**_Unity 提前定义的 5 个渲染队列_**

| 名称 | 队列索引号 | 描述 |
| --- | --------- | --- |
| Background | 1000 | 这个渲染队列会在任何其他队列之前被渲染，我们通常使用该队列来渲染那些需要绘制在背景上的物体 |
| Geometry | 2000 | **默认**的渲染队列，大多数物休都使用这个队列。不透明物体使用这个队列 |
| AlphaTest  | 2450 | 需要透明度测试的物体使用这个队列。在 Unity 5 中它从 Geometry 队列中被单独分出来，这是因为在所有不透明物体渲染之后再渲染它们会更加高效 |
| Transparent | 3000 | 这个队列中的物体会在所有 Geometry 和 AlphaTest 物体渲染后，再按从后往前的顺序进行渲染。任何使用了透明度混合（例如关闭了深度写入的 Shader) 的物体都应该使用该队列 |
| Overlay | 4000 | 该队列用于实现一些叠加效果。任何需要在最后渲染的物体都应该使用该队列 |

如果我们想要通过*透明度混合*来实现透明效果，代码中应该包含类似下面的代码：

```cs
SubShader {
  Tags { "Quene" = "Transparent" }
  Pass {
    // 关闭深度写入
    // 也可以用在 SubShader 中，表示该 SubShader 下的所有 Pass 都会关闭深度写入
    ZWrite Off
  }
}
```

### 开启深度写入的半透明效果

针对关闭深度写入实现的半透明效果存在错误排序的情况而进行优化。

**使用两个 Pass 来渲染模型**：第一个 Pass 开启深度写入，但不输出颜色，它的目的仅仅是为了把该模型的深度值写入深度缓冲中；第二个 Pass 进行正常的透明度混合，由于上 个 Pass 已经得到了逐像素的正确的深度信息，该 Pass 就可以按照像素级别的深度排序结果进行透明渲染。缺点在于，多使用一个 Pass 会对性能造成影响。

```cs
// 在透明度混合使用的Shader基础上添加一个新Pass
    ...
    // 新添加的 Pass: 目的仅仅是为了把模型的深度信息写入深度缓冲中
    Pass {
      ZWrite On
      // ColorMask 用于设置颜色通道的写掩码 (write mask)，设置为0表示不写入任何颜色通道
      // `ColorMask RGB | A | 0 | 其他任何R、 G、 B、 A的组合`
      ColorMask 0
    }
    Pass {
      ...
    }
    ...
```

### ShaderLab 的混合命令

#### 混合等式(blend equation)

已知两个操作数：源颜色 `S` 和目标颜色 `D`, 想要得到输出颜色 `O` 就必须使用一个等式来计算。我们把这个等式称为混合等式(blend equation)。

当进行混合时，我们需要使用**两个混合等式**：一个用于混合 RGB 通道，一个用于混合 A 通道。当设置混合状态时，我们实际上设置的就是混合等式中的**操作**和**因子**。在默认情况下，混合等式使用的操作都是**加操作**（我们也可以使用其他操作），我们只需要再设置一下混合因子即可。

##### 混合因子

**_Shaderlab中设置混合因子的命令_**

| 命令 | 描述 |
| --- | --- |
| `Blend SrcFactor DstFactor` | 开启混合，并设置混合因子。源颜色（该片元产生的颜色）会乘以 Srcfactor, 而目标颜色（已经存在于颜色缓存的颜色）会乘以 Dstfactor, 然后把两者相加后再存入颜色缓冲中【使用同样的混合因子来混合 RGB 通道和 A 通道】 |
| `Blend SrcFactor Dstfactor, SrcFactorA DstFactorA` | 和上面几乎一样，只是使用不同的因子来混合透明通道 |

```cs
// 两个混合等式
O_rgb = SrcFactor x S_rgb + DstFactor x D_rgb
O_a = SrcFactorA x S_a + DstFactorA x D_a
```

**_Shaderlab中的混合因子_**

| 参数 | 描述 |
| --- | --- |
| One | 因子为 `1` |
| Zero | 因子为 `0` |
| SrcColor | 因子为`源颜色值`。当用于混合 RGB 的混合等式时，使用 SrcColor 的RGB分量作为混合因子：当用于混合 A 的混合等式时，使用 SrcColor 的 A 分量作为混合因子 |
| SrcAlpha | 因子为`源颜色的透明度值(A通道)` |
| DstColor | 因子为`源颜色值`。当用于混合 RGB 通道的混合等式时，使用 DstColor 的 RGB 分量作为混合因子：当用于混合 A 通道的混合等式时，使用 DstColor 的 A 分量作为混合因子 |
| DstAlpha | 因子为`目标颜色的透明度值(A通道)` |
| OneMinusSrcColor | 因子为 `(1-源颜色)`。当用于混合RGB的混合等式时，使用结果的 RGB 分量作为混合因子：当用于混合 A 的混合等式时，使用结果的 A 分量作为混合因子 |
| OneMinusSrcAlpha | 因子为 `(1-源颜色的透明度值)` |
| OneMinusDstColor | 因子为 `(1-目标颜色)`。当用于混合RGB的混合等式时，使用结果的 RGB 分量作为混合因子：当用于混合 A 的混合等式时，使用结果的 A 分量作为混合因子 |
| OneMinusDstAlpha | 因子为 `(1-目标颜色的透明度值)` |

##### 混合操作

在默认情况下，混合等式使用的操作都是**加操作**，可以使用 ShaderLab 的`BlendOp BlendOperation` 命令，即混合操作命令来指定操作。

**_Shaderlab中的混合操作_**

| 操作 | 描述 |
| --- | --- |
| Add | 将混合后的源颜色和目的颜色相加。默认的混合操作。使用的混合等式是：`O_rgb = SrcFactor x S_rgb + DstFactor x D_rgb`, `O_a = SrcFactorA x S_a + DstFactorA x D_a` |
| Sub | 用混合后的源颜色减去混合后的目的颜色。 使用的混合等式是：使用的混合等式是：`O_rgb = SrcFactor x S_rgb - DstFactor x D_rgb`, `O_a = SrcFactorA x S_a - DstFactorA x D_a` |
| RevSub | 用混合后的目的颜色减去混合后的源颜色。使用的混合等式是：`O_rgb = DstFactor x D_rgb - SrcFactor x S_rgb`, `O_a = DstFactorA x D_a - SrcFactorA x S_a` |
| Min | 使用源颜色和目的颜色中较小的值，是逐分量比较的。使用的混合等式是：`O_rgba = (min(S_r, D_r),min(S_g, D_g),min(S_b, D_b),min(S_a, D_a))` |
| Max | 使用源颜色和目的颜色中较大的值，是逐分量比较的。使用的混合等式是：`O_rgba = (max(S_r, D_r),max(S_g, D_g),max(S_b, D_b),max(S_a, D_a))` |
| 其他逻辑操作 | 仅 DirectX 11.1 中支持 |

#### 常见混合类型

```cs
// 正常(Normal), 即透明度混合
Blend SrcAlpha OneMinusSrcAlpha
// 柔和相加(Soft Additive)
Blend OneMinusDstColor One
// 正片叠底(Multiply), 即相乘
Blend DstColor Zero
// 两倍相乘(2x Multiply)
Blend DstColor SrcColor
// 变暗(Darken)
// Min和Max混合操作会忽略混合因子
BlendOp Min
Blend One One
// 变亮(Lighten)
BlendOp Max
Blend One One
// 滤色(Screen)
Blend OneMinusDstColor One
// 等同于
Blend One OneMinusSrcColor
// 线性减淡(Linear Dodge)
Blend One One
```

![不同混合状态设置得到的效果](http://static.zybuluo.com/candycat/uvoq8qpet472e7fquzdu479t/blend.png)

### 双面渲染的透明效果

想要得到双面渲染的效果，可以使用 `Cull` 指令来控制需要剔除哪个面的渲染图元。

```cs
// Back 默认, 背对着摄像机的渲染图元就不会被渲染
// Front 朝向摄像机的渲染图元就不会被渲染
// Off 关闭剔除功能，那么所有的渲染图元都会被渲染(这时需要渲染的图元数目会成倍增加)，通常情况是不会关闭剔除功能的
Cull Back | Front | Off
```

- 透明度测试的双面渲染

```cs
// 仅在透明度测试Shader基础上添加 Cull Off
Pass {
  Tags { "LightMode"="ForwardBase" }

  Cull Off
  ...
}
```

- 透明度混合的双面渲染

把双面渲染的工作分成两个Pass，第一个 Pass 只渲染背面，第二个 Pass 只渲染正面，以保证正确的深度渲染关系。然后在两个 Pass 中分别使用 Cull 指令剔除不同朝向的渲染图元。

```cs
Pass {
  Tags { "LightMode"="ForwardBase" }
  // ++++++
  Cull Front
  ...
}
// ++++++
Pass {
  Tags { "LightMode"="ForwardBase" }

  Cull Back
  ...
}
```

## Unity Shader 动画

### Unity Shader 中的内置时间变量

| 名称 | 类型 | 描述 |
| --- | --- | --- |
| _Time | float4 | t 是自该场景加载开始所经过的时间，4 个分量的值分别是 `(t/20, t, 2t, 3t)`。 |
| _SinTime | float4 | t 是时间的正弦值，4 个分量的值分别是 `(t/8, t/4, t/2, t)` |
| _CosTime | float4 | t 是时间的正弦值，4 个分量的值分别是 `(t/8, t/4, t/2, t)` |
| unity_DeltaTime | float4 | dt 是时间增量，4 个分量的值分别是 `(dt, 1/dt, smoothDt, 1/smoothDt)` |

### 纹理动画

纹理动画在游戏中的应用非常广泛。尤其在各种资源都比较局限的移动平台上，往往会使用纹理动画来代替复杂的粒子系统等模拟各种动画效果。

#### 序列帧动画

序列帧动画的**原理**：依次播放一系列关键帧图像，当播放速度达到一定数值时，看起来就是一个连续的动画。**优点**：灵活性很强，不需要进行任何物理计算就可以得到非常细腻的动画效果。**缺点**：序列帧中每张关键帧图像都不一样，要制作一张出色的序列帧纹理所需要的美术工程量比较大。

```cs
Shader "Unlit/Chapter11-ImageSequenceAnimation"
{
  Properties {
    _Color ("Color Tint", Color) = (1,1,1,1)
    _MainTex ("Image Sequence", 2D) = "white" {}
    _HorizontalAmount ("Horizontal Amount", Float) = 8
    _VerticalAmount ("Vertical Amount", Float) = 8
    _Speed ("Speed", Range(1, 100)) = 30
  }
  SubShader {
    Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

    Pass {
      Tags { "LightMode" = "ForwardBase" }

      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

      fixed4 _Color;
      sampler2D _MainTex;
      float4 _MainTex_ST;
      float _HorizontalAmount;
      float _VerticalAmount;
      float _Speed;

      struct a2v {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        float time = floor(_Time.y * _Speed);
        float row = floor(time / _HorizontalAmount);
        float column = time - row * _VerticalAmount;

        half2 uv = i.uv + half2(column, -row);
        uv.x /= _HorizontalAmount;
        uv.y /= _VerticalAmount;

        fixed4 c = tex2D(_MainTex, uv);
        c.rgb *= _Color;
        return c;
      }

      ENDCG
    }
  }
  FallBack "Transparent/VertexLit"
}

```

#### 滚动的背景

利用内置的 `_Time.y` 变量在水平方向上对纹理坐标进行偏移，以此达到滚动的效果。

```cs
Shader "Unlit/Chapter11-ScrollingBackground"
{
  Properties
  {
    _MainTex ("Base Layer (RGB)", 2D) = "white" {}
    _DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
    _ScrollX ("Base Layer Scroll Speed", Float) = 1.0
    _Scroll2X ("2nd Layer Scroll Speed", Float) = 1.0
    // 控制纹理的整体亮度
    _Multiplier ("Layer Multiplier", Float) = 1
  }
  SubShader
  {
    Tags { "RenderType"="Opaque" "Queue"="Geometry"}

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        float4 uv : TEXCOORD0;
      };

      struct v2f
      {
        float4 vertex : SV_POSITION;
        float4 uv : TEXCOORD0;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;
      sampler2D _DetailTex;
      float4 _DetailTex_ST;
      float _ScrollX;
      float _Scroll2X;
      float _Multiplier;

      v2f vert (appdata v)
      {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
        o.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
        return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
        // sample the texture
        fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
        fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
        // 使用第二层纹理的透明通道来混合两张纹理
        fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
        c.rgb *= _Multiplier;

        return c;
      }
      ENDCG
    }
  }
  Fallback "VertexLit"
}
```

### 顶点动画

顶点动画通常用来模拟旗帜飘动、水流流动等效果。

#### 水流流动

原理通常是使用**正弦函数**等来模拟水流的波动效果。

#### 广告牌技术(Billboarding)

广告牌技术会根据视角方向来**旋转**一个被纹理着色的多边形（通常就是简单的四边形，这个多边形就是广告牌），使得多边形看起来好像总是面对着摄像机。其本质就是构建**旋转矩阵**[广告牌技术使用的基向量通常是**表面法线(normal)**、**指向上的方向(up)**以及**指向右的方向(right)，还需要指定一个固定的锚点(anchor location)**]。广告牌技术被用于很多场景，比如渲染烟雾、云朵、闪光效果等。

广告牌技术的难点在于，如何根据需求来构建3个相互正交的基向量。基向量计算过程如下：

1. 通过初始计算得到目标的表面法线（例如就是视角方向）和指向上的方向。两者往往是不垂直的，但两者其中之一是固定的【如当模拟草丛时， 我们希望广告牌的指向上的方向永远是 `(0, 1, 0)`, 而法线方向应该随视角变化；而当模拟粒子效果时，我们希望广告牌的法线方向是固定的，即总是指向视角方向，指向上的方向则可以发生变化】
2. 假设法线方向固定，根据初始的表面法线和指向上的方向来计算(叉积)出目标方向的指向右的方向 `right = up x normal`，对其归一化后，再由法线方向和指向右的方向计算出正交的指向上的方向 `up' = normal x right`

```cs
Shader "Unlit/Chapter11-Billboard"
{
  Properties
  {
    _MainTex ("Main Texture", 2D) = "white" {}
    _Color ("Color Tint", Color) = (1,1,1,1)
    // 用于调整是固定法线还是固定指向上的方向，即约束垂直方向的程度
    _VerticalBillboarding ("Vertical BillBoarding", Range(0, 1)) = 1
  }
  SubShader
  {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True" }

    Pass
    {
      Tags { "LightMode"="ForwardBase" }
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha
      Cull Off

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f
      {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;
      fixed4 _Color;
      fixed _VerticalBillboarding;

      v2f vert (appdata v)
      {
        v2f o;
        // 选择模型空间的原点作为广告牌的锚点
        float3 center = float3(0,0,0);
        // 获取模型空间下的视角位置
        float3 viewer = mul(unity_ObjectToWorld, float4(_WorldSpaceCameraPos, 1));
        // 计算三个正交矢量
        // 目标法线方向
        float3 normalDir = viewer - center;
        // 当 _VerticalBillboarding 为 1 时，意味着法线方向固定为视角方向；当 _VerticalBillboarding 为 0 时，意味着向上方向固定为 (0, 1, 0)
        normalDir.y = normalDir.y * _VerticalBillboarding;
        normalDir = normalize(normalDir);
        // 粗略的向上方向
        // 防止法线方向和向上方向平行
        float3 upDir = abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0);
        // 向右方向
        float3 rightDir = normalize(cross(upDir, normalDir));
        upDir = normalize(cross(normalDir, rightDir));
        /// 重新计算顶点位置
        float3 centerOffs = v.vertex.xyz - center;
        float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir.z * centerOffs.z;
        o.vertex = UnityObjectToClipPos(float4(localPos, 1));
        return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
        // sample the texture
        fixed4 col = tex2D(_MainTex, i.uv);
        col.rgb *= _Color.rgb;
        return col;
      }
      ENDCG
    }
  }
  Fallback "Transparent/VertexLit"
}

```

#### 顶点动画注意事项

- 批处理往往会破坏这种动画效果，可以通过 `SubShader` 的 `DisableBatching` 标签来强制取消对该 UnityShader 的批处理。然而，取消批处理会带来一定的性能下降，增加了Draw Call，因此应该尽量避免使用模型空间下的一些绝对位置和方向来进行计算(在广告牌的例子中，为了避免显式使用模型空间的中心来作为铀点，可以利用顶点颜色来存储每个顶点到错点的距离值)。
- 如果想要对包含了顶点动画的物体添加阴影，得不到正确的阴影效果(投影错误)，此时需要提供自定义的 `ShadowCaster Pass`，如下带代码。阴影投射的重点在于需要按正常Pass的处理来剔除片元或进行顶点动画，以便阴影可以和物体正常渲染的结果相匹配。

```cs
Pass {
  Tags { "LightMode"="ShadowCaster" }
  CGPROGRAM

  #pragma vertex vert
  #pragma fragment frag
  #pragma multi_compile_shadowcaster

  #include "UnityCG.cginc"

  float _Magnitude;
  float _Frequency;
  float _InvWaveLength;
  float _Speed;

  struct a2v {
    float4 vertex : POSITION;
    float4 texcoord : TEXCOORD0;
  };

  struct v2f {
    V2F_SHADOW_CASTER;
  };

  v2f vert(a2v v) {
    v2f o;
    float4 offset;

    offset.yzw = float3(0,0,0);
    offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
    v.vertex += offset;

    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

    return o;
  }

  fixed4 frag(v2f i) : SV_Target {
    SHADOW_CASTER_FRAGMENT(i)
  }
  ENDCG
}
```

## 屏幕后处理效果

[Post-processing overview](https://docs.unity3d.com/Manual/PostProcessingOverview.html)

**屏幕后处理**，通常指的是在渲染完整个场景得到屏幕图像后，再对这个图像进行一系列操作，实现各种屏幕特效。使用这种技术，可以为游戏画面添加更多的艺术效果，例如景深 (Depth of Field) 、运动模糊 (Motion Blur) 等。

实现屏幕后处理的基础在于得到渲染后的屏幕图像，即抓取屏幕，Unity 提供了一个接口 `OnRenderImage` 函数。当我们在脚本中声明此函数后，Unity 会把当前渲染得到的图像存储在第一个参数对应的源渲染纹理中，通过函数中的操作后再把目标渲染纹理(即第二个参数对应的渲染纹理)显示到屏幕上。

在默认情况下，`OnRenderImage` 函数会在所有的不透明和透明的 Pass执行完毕后被调用，以便对场景中所有游戏对象都产生影响。

```cs
MonoBehaviour.OnRenderImage (RenderTexture src, RenderTexture dest)
```

在 `OnRenderImage` 函数中，通常是利用 `Graphics.Blit` 函数来完成对渲染纹理的处理。若希望不对透明物体产生任何影响，可在 `OnRenderImage` 函数前添加 `ImageEffectOpaque` 属性来实现。

```cs
/// src 源纹理，这个参数通常是当前屏幕的渲染纹理或是上一步处理后得到的渲染纹理
/// desc 目标渲染纹理，如果它的值为 null 就会直接将结果显示在屏幕上
public static void Blit(Texture src, RenderTexture dest);
/// mat 材质，这个材质使用的 Unity Shader 将会进行各种屏幕后处理操作，src 纹理将会被传递给 Shader 中名为 _MainTex 的纹理属性
/// pass 的默认值为 -1, 指定依次调用 Shader 内的所有 Pass
public static void Blit(Texture src, RenderTexture dest, Material mat, int pass = -1);
public static void Blit(Texture src, Material mat, int pass = -1);
```

_**在 Unity 中实现屏幕后处理效果**_

- 在进行屏幕后处理之前，需要检查一系列条件是否满足，例如当前平台是否支持渲染纹理和屏幕特效，是否支持当前使用的 Unity Shader 等，示例代码如下。
- 在摄像中添加用于屏幕后处理的脚本。在脚本中实现 `OnRenderImage` 函数来获取当前屏幕的渲染纹理。
- 调用 `Graphics.Blit` 函数使用特定的 Unity Shader 来对当前图像进行处理，再把返回的渲染纹理显示到屏幕上（复杂的屏幕特效可能需要多次调用 `Graphics.Blit` 函数）。

```cs
using UnityEngine;
using System.Collections;

// 编辑模式下也可以执行该脚本
[ExecuteInEditMode]
// 所有屏幕后处理效果都需要绑定在某个摄像机上
[RequireComponent (typeof(Camera))]
/// <summary>
/// 在进行屏幕后处理之前，需要检查一系列条件是否满足
/// <summary>
public class PostEffectsBase : MonoBehaviour {

  // Called when start
  // 提前检查各种资源和条件是否满足
  protected void CheckResources() {
    bool isSupported = CheckSupport();

    if (isSupported == false) {
      NotSupported();
    }
  }

  // Called in CheckResources to check support on this platform
  protected bool CheckSupport() {
    if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false) {
      Debug.LogWarning("This platform does not support image effects or render textures.");
      return false;
    }

    return true;
  }

  // Called when the platform doesn't support this effect
  protected void NotSupported() {
    enabled = false;
  }
  
  protected void Start() {
    CheckResources();
  }

  // Called when need to create the material used by this effect
  protected Material CheckShaderAndCreateMaterial(Shader shader, Material material) {
    if (shader == null) {
      return null;
    }

    if (shader.isSupported && material && material.shader == shader)
      return material;

    if (!shader.isSupported) {
      return null;
    }
    else {
      material = new Material(shader);
      material.hideFlags = HideFlags.DontSave;
      if (material)
        return material;
      else
        return null;
    }
  }
}
```

### 调整亮度、饱和度、对比度

创建一个继承自 `PostEffectsBase` 的脚本 `BrightnessSaturationAndContrast`

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase {

  public Shader briSatConShader;
  private Material briSatConMaterial;
  public Material material {
    get {
      briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
      return briSatConMaterial;
    }
  }
  [Range(0.0f, 3.0f)]
  public float brightness = 1.0f;
  
  [Range(0.0f, 3.0f)]
  public float saturation = 1.0f;
  
  [Range(0.0f, 3.0f)]
  public float contrast = 1.0f;

  void OnRenderImage(RenderTexture src, RenderTexture dest)
  {
    if(null != material)
    {
      material.SetFloat("_Brightness", brightness);
      material.SetFloat("_Saturation", saturation);
      material.SetFloat("_Contrast", contrast);
      Graphics.Blit(src, dest, material);
    }
    else
    {
      Graphics.Blit(src, dest);
    }
  }
}
```

编写 Shader 并应用在脚本上

```cs
Shader "Unlit/BrightnessSaturationAndContrast"
{
  Properties
  {
    // 必须叫 _MainTex, 供 Graphics.Blit(src, dest, material) 用
    _MainTex ("Main Texture", 2D) = "white" {}
    _Brightness ("Brightness", Float) = 1
    _Saturation ("Saturation", Float) = 1
    _Contrast ("Contrast", Float) = 1
  }
  SubShader
  {
    Pass {
      // 屏幕后处理标配设置
      ZTest Always Cull Off ZWrite Off

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "unityCG.cginc"

      sampler2D _MainTex;
      half _Brightness;
      half _Saturation;
      half _Contrast;

      struct v2f {
        float4 pos : POSITION;
        half2 uv : TEXCOORD;
      };

      v2f vert(appdata_img v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed4 renderTex = tex2D(_MainTex, i.uv);
        // 应用亮度参数
        float3 finalColor = renderTex.rgb * _Brightness;
        // 应用饱和度参数
        /// 计算该像素对应的亮度值 (lumjnance)
        fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
        fixed3 luminanceColor =fixed3(luminance,luminance,luminance);
        finalColor = lerp(luminanceColor, finalColor, _Saturation);
        // 应用对比度
        fixed3 avgColor = fixed3(0.5,0.5,0.5);
        finalColor = lerp(avgColor,finalColor,_Contrast);
        return fixed4(finalColor, renderTex.a);
      }
      ENDCG
    }
  }

  FallBack Off
}
```

### 边缘检测

边缘检测的原理是利用一些边缘检测算子对图像进行**卷积 (convolution)**操作。

#### 卷积

在图像处理中，**卷积**操作指的就是使用一个**卷积核 (kernel)** 对一张图像中的每个像素进行一系列操作。卷积核通常是一个四方形网格结构（例如 2x2、 3x3 的方形区域），该区域内每个方格都有一个权重值。当对图像中的某个像素进行卷积时，我们会把卷积核的中心放置于该像素上，翻转核之后再依次计算核中每个元素和其覆盖的图像像素值的乘积并求和，得到的结果就是该位置的新像素值。可以实现很多常见的图像处理效果， 例如**图像模糊**、**边缘检测**等。

![卷积核与卷积](http://static.zybuluo.com/candycat/dvch7lp9z5d9rp4o0c1edjep/convolution.png)

#### 边缘检测算子

> 3 种常见的边缘检测算子(都包含了两个方向的卷积核，分别用于检测水平方向和竖直方向上的边缘信息)

![3种常见的边缘检测算子](http://static.zybuluo.com/candycat/bm2nnarbl2h6fmmjq1gsfb7c/edge_detection_kernel.png)

在进行边缘检测时，需要对每个像素分别进行一次卷积计算，得到两个方向上的梯度值 `Gx` 和 `Gy`, 而整体的梯度可按下面的公式计算而得。可以据此来判断哪些像素对应了边缘（梯度值越大，越有可能是边缘点）。

```cs
G = sqrt(Gx^2 + Gy^2)

// 计算包含了开根号操作，出于性能的考虑，有时会使用绝对值操作来代替开根号操作
G = |Gx| + |Gy|
```

> 示例代码

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase {
  public Shader edgeDetectShader;
  private Material edgeDetectMaterial = null;
  public Material material {
    get {
      edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader,edgeDetectMaterial);
      return edgeDetectMaterial;
    }
  }
  [Range(0.0f,1.0f)]
  public float edgesOnly = 0.0f;
  public Color edgeColor = Color.black;
  public Color backgroundColr = Color.white;

  void OnRenderImage(RenderTexture src, RenderTexture dest)
  {
    if(null != material) {
      material.SetFloat("_EdgeOnly", edgesOnly);
      material.SetColor("_EdgeColor", edgeColor);
      material.SetColor("_BackgroundColor", backgroundColr);
      Graphics.Blit(src, dest, material);
    } else {
      Graphics.Blit(src, dest);
    }
  }
}
```

```cs
Shader "Unlit/EdgeDetection"
{
  Properties
  {
    _MainTex ("Main Texture", 2D) = "white" {}
    _EdgeOnly ("Edge Only", Float) = 1.0
    _EdgeColor ("Edge Color", Color) = (0,0,0,1)
    _BackgroundColor ("Background Color", Color) = (1,1,1,1)
  }
  SubShader
  {
    Pass
    {
      ZTest Always Cull Off ZWrite Off

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment fragSobel

      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        half2 uv : TEXCOORD0;
      };

      struct v2f
      {
        half2 uv[9] : TEXCOORD0;
        float4 vertex : SV_POSITION;
      };

      sampler2D _MainTex;
      half4 _MainTex_TexelSize;
      fixed _EdgeOnly;
      fixed4 _EdgeColor;
      fixed4 _BackgroundColor;

      v2f vert (appdata v)
      {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        half2 uv = v.uv;
        // 9 的纹理数组值对应了使用 Sobel 算子采样时需要的 9 个邻域纹理坐标
        // 把计算采样纹理坐标的代码从片元着色器中转移到顶点着色器中，可以减少运算，提高性能
        o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
        o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
        o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
        o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
        o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
        o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
        o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
        o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
        o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
        return o;
      }

      fixed luminance(fixed4 color) {
        return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
      }

      half Sobel(v2f i) {
        // 定义了水平方向和竖直方向使用的卷积核 Gx 和 Gy
        const half Gx[9] = {
          -1,  0,  1,
          -2,  0,  2,
          -1,  0,  1
        };
        const half Gy[9] = {
          -1, -2, -1,
          0,  0,  0,
          1,  2,  1
        };

        half texColor;
        half edgeX = 0;
        half edgeY = 0;
        // 依次对9个像素进行采样，计算它们的亮度值，
        // 再与卷积核Gx和Gy中对应的权重相乘后，叠加到各自的梯度值上
        for (int it = 0; it < 9; it++) {
          texColor = luminance(tex2D(_MainTex, i.uv[it]));
          edgeX += texColor * Gx[it];
          edgeY += texColor * Gy[it];
        }
        // 从1中减去水平方向和竖直方向的梯度值的绝对值，得到edge
        half edge = 1 - abs(edgeX) - abs(edgeY);

        return edge;
      }

      fixed4 fragSobel (v2f i) : SV_Target
      {
        half edge = Sobel(i);
        fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
        fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
        return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
      }
      ENDCG
    }
  }
  FallBack Off
}
```

### 边缘检测优化

使用 Sobel 算子对屏幕图像进行边缘检测实现描边的效果会产生很多不希望得到的边缘线，如物体的纹理、阴影等位置会被描上边缘。另一种更加可靠的方式是**在深度和法线纹理上进行边缘检测**，它使用的是**Roberts 算子**，Roberts 算子的本质是计算左上角和右下角的差值，乘以右上角和左下角的差值， 作为评估边缘的依据。

![Roberts 算子](http://static.zybuluo.com/candycat/ziah5yj1twj4nva7ldvw8dnk/Roberts.png)

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepth : PostEffectsBase {
  public Shader edgeDetectShader;
  private Material edgeDetectMaterial = null;
  public Material material {  
    get {
      edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
      return edgeDetectMaterial;
    }  
  }

  [Range(0.0f, 1.0f)]
  public float edgesOnly = 0.0f;

  public Color edgeColor = Color.black;

  public Color backgroundColor = Color.white;
  // 控制对深度+法线纹理采样时，使用的采样距离，值越大，描边越宽
  public float sampleDistance = 1.0f;
  // 影响当邻域的深度值或法线值相差多少时，会被认为存在一条边界
  public float sensitivityDepth = 1.0f;
  public float sensitivityNormals = 1.0f;
  
  void OnEnable() {
    GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
  }

  // 在不透明的 Pass (即渲染队列小于等于 2500 的 Pass，
  // 内置的 Background、Geometry 和 AlphaTest 渲染队列均在此范围内）执行完毕后立即调用该函数，
  // 而不对透明物体（渲染队列为 Transparent 的 Pass) 产生影响
  [ImageEffectOpaque]
  void OnRenderImage (RenderTexture src, RenderTexture dest) {
    if (material != null) {
      material.SetFloat("_EdgeOnly", edgesOnly);
      material.SetColor("_EdgeColor", edgeColor);
      material.SetColor("_BackgroundColor", backgroundColor);
      material.SetFloat("_SampleDistance", sampleDistance);
      material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

      Graphics.Blit(src, dest, material);
    } else {
      Graphics.Blit(src, dest);
    }
  }
}
```

```cs
Shader "Unlit/Chapter13-EdgeDetectNormalsAndDepth"
{
  Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _EdgeOnly ("Edge Only", Float) = 1.0
    _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
    _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
    _SampleDistance ("Sample Distance", Float) = 1.0
    _Sensitivity ("Sensitivity", Vector) = (1, 1, 1, 1)
  }
  SubShader {
    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    // 用于对邻域像素进行纹理采样
    half4 _MainTex_TexelSize;
    fixed _EdgeOnly;
    fixed4 _EdgeColor;
    fixed4 _BackgroundColor;
    float _SampleDistance;
    half4 _Sensitivity;

    sampler2D _CameraDepthNormalsTexture;

    struct v2f {
      float4 pos : SV_POSITION;
      half2 uv[5]: TEXCOORD0;
    };

    v2f vert(appdata_img v) {
      v2f o;
      o.pos = UnityObjectToClipPos(v.vertex);

      half2 uv = v.texcoord;
      o.uv[0] = uv;

      #if UNITY_UV_STARTS_AT_TOP
      if (_MainTex_TexelSize.y < 0)
        uv.y = 1 - uv.y;
      #endif
      // 存储使用 Roberts 算子时需要采样的纹理坐标，乘上 _SampleDistance 用于控制采样距离
      o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1,1) * _SampleDistance;
      o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance;
      o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,1) * _SampleDistance;
      o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1,-1) * _SampleDistance;

      return o;
    }

    // 分别计算对角线上两个纹理值的差值
    half CheckSame(half4 center, half4 sample) {
      half2 centerNormal = center.xy;
      float centerDepth = DecodeFloatRG(center.zw);
      half2 sampleNormal = sample.xy;
      float sampleDepth = DecodeFloatRG(sample.zw);
      // difference in normals
      // do not bother decoding normals - there's no need here
      half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
      int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
      // difference in depth
      float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
      // scale the required threshold by the distance
      int isSameDepth = diffDepth < 0.1 * centerDepth;
      // return:
      // 1 - if normals and depth are similar enough
      // 0 - otherwise
      return isSameNormal * isSameDepth ? 1.0 : 0.0;
    }

    fixed4 fragRobertsCrossDepthAndNormal(v2f i) : SV_Target {
      half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
      half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
      half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
      half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

      half edge = 1.0;
      // 得到边缘信息后
      edge *= CheckSame(sample1, sample2);
      edge *= CheckSame(sample3, sample4);
      // 颜色混合
      fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
      fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

      return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
    }
    ENDCG
    Pass {
      ZTest Always Cull Off ZWrite Off
      CGPROGRAM
      #pragma vertex vert  
      #pragma fragment fragRobertsCrossDepthAndNormal
      ENDCG  
    }
  }
  FallBack Off
}
```

### 高斯模糊

**高斯模糊**是卷积的另一个常见应用，它使用的卷积核名为**高斯核**，高斯核是一个正方形大小的滤波核，其中每个元素的计算都是基于下面的高斯方程：

要构建一个高斯核，只需要计算高斯核中各个位置对应的高斯值。为了保证滤波后的图像不
会变暗，需要对高斯核中的权重进行归一化，即让每个权重除以所有权重的和，这样可以保
证所有权重的和为1。

高斯核的维数越高，模糊程度越大。使用一个 `NxN` 的高斯核对图像进行卷积滤波，就需要 `NxNxWxH` (W 和H分别是图像的宽和高)次纹理采样。当 `N` 的大小不断增加时，采样次数会变得非常巨大。可以把这个二维高斯函数拆分成两个一维函数，可以使用两个一维高斯核先后对图像进行滤波，采样次数只需要 `2xNxWxH`，优化性能的同时得到同样的效果。

![一个5x5大小的高斯核。左图显示了标准方差为 1 的高斯核的权重分布，我们可以把这个二维高斯核拆分成两个一维的高斯核(右)](http://static.zybuluo.com/candycat/qdi1a1gaicihr3tju2acbcdc/gaussian_kernel.png)

高斯方程很好地模拟了邻域每个像素对当前处理像素的影响程度：距离越近，影响越大。

```cs
// σ是标准方差（一般取值为1)
// x和y 分别对应了当前位置到卷积核中心的整数距离
G(x,y) = (1/2πσ^2)e^[-(x^2+y^2)/(2σ^2)]
```

> GaussianBlur.cs 代码

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase {

  public Shader gaussianBlurShader;
  private Material gaussianBlurMaterial = null;
  public Material material {
    get {
      gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
      return gaussianBlurMaterial;
    }
  }
  // 模糊迭代次数
  [Range(0, 4)]
  public int iterations = 3;
  // 模糊范围控制
  [Range(0.2f, 3.0f)]
  public float blurSpread = 0.6f;
  // 缩放系数
  [Range(1, 8)]
  public int downSample = 2;

  void OnRenderImage(RenderTexture src, RenderTexture dest) {
    if(null != material) {
      /*****************1st****************
      int rtW = src.width;
      int rtH = src.height;
      // 分配一块与屏幕大小相同的缓冲区
      RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
      // 使用竖直方向的一维高斯核进行滤波并将结果存储在 buffer 中
      Graphics.Blit(src, buffer, material, 0);
      // 使用水平方向的一维高斯核进行滤波对 buffer 进行处理得到屏幕图像
      Graphics.Blit(buffer, dest, material, 1);
      // 释放缓存
      RenderTexture.ReleaseTemporary(buffer);
      *************************************/
      // 对图像进行降采样
      // !!过大的 downSample 可能会造成图像像素化
      int rtW = src.width / downSample;
      int rtH = src.height / downSample;
      // 把 src 中的图像缩放后存储到 buffer0 中
      RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
      // 将临时渲染纹理的滤波模式设为双线性
      buffer0.filterMode = FilterMode.Bilinear;

      Graphics.Blit(src, buffer0);
      for (int i = 0; i < iterations; i++)
      {
        material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
        RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
        Graphics.Blit(buffer0, buffer1, material, 0);
        RenderTexture.ReleaseTemporary(buffer0);

        buffer0 = buffer1;
        buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

        Graphics.Blit(buffer0, buffer1, material, 1);
        RenderTexture.ReleaseTemporary(buffer0);
        buffer0 = buffer1;
      }
      Graphics.Blit(buffer0, dest);
      RenderTexture.ReleaseTemporary(buffer0);
    } else {
      Graphics.Blit(src, dest);
    }
  }
}
```

```cs
Shader "Unlit/Chapter12-GaussianBlur"
{
  Properties
  {
    _MainTex ("Texture", 2D) = "white" {}
    // 控制不同迭代之间高斯模糊的模糊区域范围
    _BlurSize ("Blur Size", Float) = 1.0
  }
  SubShader
  {
    // CGINCLUDE类似于 C++ 中头文件的功能
    // 高斯模糊需要定义两个 Pass, 但它们使用的片元着色器代码完全相同
    // 使用CGINCLUDE可以避免我们编写两个完全一样的 frag 函数。
    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    // 计算相邻像素的纹理坐标偏移量以得到相邻像素的纹理坐标
    half4 _MainTex_TexelSize;
    float _BlurSize;

    struct v2f {
      float4 pos : SV_POSITION;
      half2 uv[5] : TEXCOORD0;
    };
    // 竖直方向的顶点着色器
    // 用 5x5 大小的高斯核对原图像进行高斯模糊
    v2f vertBlurVertical(appdata_img v) {
      v2f o;
      o.pos = UnityObjectToClipPos(v.vertex);
      half2 uv = v.texcoord;

      o.uv[0] = uv;
      // 在高斯核维数不变的情况下，_BlurSize 越大，模糊程度越高，但采样数却不会受到影响
      // !!过大的_BlurSize 值会造成虚影
      o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
      o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
      o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
      o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

      return o;
    }
    // 水平方向的顶点着色器
    v2f vertBlurHorizontal(appdata_img v) {
      v2f o;
      o.pos = UnityObjectToClipPos(v.vertex);

      half2 uv = v.texcoord;

      o.uv[0] = uv;
      o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
      o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
      o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
      o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

      return o;
    }
    fixed4 fragBlur(v2f i) : SV_Target {
      // 5x5 的二维高斯核可以拆分成两个大小为 5 的一维高斯核
      // 由于它的对称性，只需要记录 3 个高斯权重
      float weight[3] = { 0.4026, 0.2442, 0.0545 };
      fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
      for (int it = 1; it < 3; it++) {
        sum += tex2D(_MainTex, i.uv[it]).rgb * weight[it];
        sum += tex2D(_MainTex, i.uv[2*it]).rgb * weight[it];
      }
      return fixed4(sum, 1.0);
    }
    ENDCG

    ZTest Always Cull Off ZWrite Off

    Pass {
      // 为 Pass 定义名字，可以在其他 Shader 中直接通过它们的名字来使用该 Pass, 而不需要再重复编写代码
      NAME "GAUSSIAN_BLUR_VERTICAL"

      CGPROGRAM

      #pragma vertex vertBlurVertical;
      #pragma fragmemt fragBlur;

      ENDCG
    }

    Pass {
      NAME "GAUSSIAN_BLUR_HORIZONTAL"

      CGPROGRAM

      #pragma vertex vertBlurHorizontal;
      #pragma fragmemt fragBlur;

      ENDCG
    }
  }
  FallBack "Diffuse"
}
```

### Bloom 效果

模拟真实摄像机的一种图像效果，让画面中较亮的区域 _扩散_ 到周围的区域中，造成一种朦胧的效果。

> 实现原理

- 根据一个阈值提取出图像中的较亮区域，把它们存储在一张渲染纹理中
- 利用高斯模糊对上面得到的渲染纹理进行模糊处理，模拟扩散光线的效果
- 将模拟扩散效果与原图混合，得到最终效果

> Bloom.cs 脚本的代码与 GaussianBlur.cs 基本一致，只增加了一个新的参数 `luminanceThreshold` 来控制提取较亮区域时使用的阈值

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase
{
    public Shader bloomShader;
    private Material bloomMaterial = null;
    public Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }
    // 模糊迭代次数
    [Range(0, 4)]
    public int iterations = 3;
    // 模糊范围控制
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    // 缩放系数
    [Range(1, 8)]
    public int downSample = 2;
    // 控制提取较亮区域时使用的阈值
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (null != material)
        {
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            // 对图像进行降采样
            // !!过大的 downSample 可能会造成图像像素化
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            // 把 src 中的图像缩放后存储到 buffer0 中
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            // 将临时渲染纹理的滤波模式设为双线性
            buffer0.filterMode = FilterMode.Bilinear;
            // 使用 Shader 中的第一个 Pass 提取图像中的较亮区域并存储在 buffer0 中
            Graphics.Blit(src, buffer0, material, 0);
            // 高斯模糊迭代使用第二个和第三个 Pass
            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the vertical pass
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the horizontal pass
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            // 使用第四个 Pass 进行最终混合
            material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(src, dest, material, 3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
```

> Shader 代码

```cs
Shader "Unlit/Chapter12-Bloom"
{
  Properties
  {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    // 高斯模糊后的较亮区域
    _Bloom ("Bloom (RGB)", 2D) = "black" {}
    // 用于提取较亮区域使用的阈值
    _LuminanceThreshold ("Luminance Threshold", Float) = 0.5
    // 控制不同迭代之间高斯模糊的模糊区域范围
    _BlurSize ("Blur Size", Float) = 1.0
  }
  SubShader
  {
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    half4 _MainTex_TexelSize;
    sampler2D _Bloom;
    float _LuminanceThreshold;
    float _BlurSize;
    /// 提取较亮区域需要使用的顶点着色器和片元着色器
    struct v2f {
      float4 pos : SV_POSITION;
      half2 uv : TEXCOORD0;
    };

    v2f vertExtractBright(appdata_img v) {
      v2f o;
      o.pos = UnityObjectToClipPos(v.vertex);
      o.uv = v.texcoord;
      return o;
    }

    fixed luminance(fixed4 color) {
      return 0.2125 * color.r + 0.7154 * color.g + 0.00721 * color.b;
    }

    fixed4 fragExtractBright(v2f i) : SV_Target {
      fixed4 c = tex2D(_MainTex, i.uv);
      // 采样到的亮度值减去阈值，截取 0-1 之间
      fixed val = clamp(luminance(c) - _LuminanceThreshold, 0.0, 1.0);
      // 返回提取后的亮部区域
      return c * val;
    }

    /// 混合亮部图像和原图像时使用的顶点着色器和片元着色器
    struct v2fBloom {
      float4 pos : SV_POSITION;
      half4 uv : TEXCOORD0;
    };

    v2fBloom vertBloom(appdata_img v) {
      v2fBloom o;
      o.pos = UnityObjectToClipPos(v.vertex);
      o.uv.xy = v.texcoord;
      o.uv.zw = v.texcoord;

      #if UNITY_UV_STARTS_AT_TOP
      if(_MainTex_TexelSize.y < 0) {
        o.uv.w = 1.0 - o.uv.w;
      }
      #endif
      return o;
    }
    fixed4 fragBloom(v2fBloom i) : SV_Target {
      return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
    }
    ENDCG
    ZTest Always Cull Off ZWrite Off

    Pass {
      CGPROGRAM
      #pragma vertex vertExtractBright
      #pragma fragment fragExtractBright
      ENDCG
    }
    // 使用高斯模糊定义的 Pass
    UsePass "Unlit/Chapter12-GaussianBlur/GAUSSIAN_BLUR_VERTICAL"

    UsePass "Unlit/Chapter12-GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

    Pass {
      CGPROGRAM
      #pragma vertex vertBloom
      #pragma fragment fragBloom
      ENDCG
    }
  }
  FallBack Off
}
```

### 动态模糊

如果在摄像机曝光时，拍摄场景发生了变化，就会产生模糊的画面。实现方法有两种：

- **累积缓存**：利用一块累积缓存 (accumulation buffer) 来混合多张连续的图像。当物体快速移动产生多张图像后，我们取它们之间的平均值作为最后的运动模糊图像。这种暴力的方法对**性能的消耗很大**。
- **[速度缓冲](速度缓冲实现运动模糊)**：创建和使用速度缓冲 (velocity buffer)，这个缓存中存储了各个像素当前的运动速度，然后利用该值来决定模糊的方向和大小。这种方法应用更广泛。

## 深度纹理和法线纹理

### 获取深度纹理和法线纹理

深度纹理存储的像素值不是颜色值，而是一个高精度(深度纹理的精度通常是 24位或16位，这取决于使用的深度缓存的精度。)的**深度值**，深度值来自于顶点变换后得到的**归一化的设备坐标 (Normalized Device Coordinates, NDC)**。深度值范围是 `[0, 1]`,而且通常是非线性分布的。

在 Unity 中，深度纹理可以直接来自于真正的**深度缓存**，也可以是由一个**单独的Pass渲染**而得，这取决于使用的渲染路径和硬件。

  1. 当使用延迟渲染路径（包括遗留的延迟渲染路径）时，深度纹理可以直接访问到，因为延迟渲染会把这些信息渲染到 G-buffer 中。
  2. 无法直接获取深度缓存时，深度和法线纹理是通过一个单独的Pass渲染而得的。具体实现是，Unity 会使用**着色器替换(Shader Replacement)技术**选择那些渲染类型（即 SubShader 的 RenderType 标签）为 Opaque 的物体，判断它们使用的渲染队列是否小于等于 2500 (内置的 Background、Geometry 和 AlphaTest 渲染队列均在此范围内），如果满足条件，就把它渲染到深度和法线纹理中。因此，要想让物体能够出现在深度和法线纹理中，就必须在 Shader 中设置正确的 RenderType 标签。

在 Unity 中，可以选择让一个摄像机生成一张**深度纹理**或是一张**深度+法线纹理**。

  1. 只需要一张单独的深度纹理时，Unity 会直接获取深度缓存或是按之前讲到的着色器替换技术，选取需要的不透明物体，并使用它投射阴影时使用的 Pass (即LightMode 被设置为 ShadowCaster 的 Pass) 来得到深度纹理。
  获取深度纹理后就可以使用当前像素的纹理坐标对它进行采样。绝大多数情况下，可以直接使用 `tex2D` 函数采样，但在某些平台 （例如 PS3 和 PSP2) 上，Unity 为我们提供了一个统一的宏 `SAMPLE_DEPTH_TEXTURE` 用来采样。类似的宏还有`SAMPLE_DEPTH_TEXTURE_PROJ` 和 `SAMPLE_DEPTH_TEXTURE_LOD`。这些宏定义在 `HLSLSupport.cginc` 中。
  2. 如果选择生成一张深度+法线纹理，Unity 会创建一张和屏幕分辨率相同、精度为 32 位（每个通道为 8 位）的纹理，其中观察空间下的法线信息会被编码进纹理的 R 和 G 通道，而深度信息会被编码进 B 和 A 通道。

```cs
// 获取深度纹理，通过在脚本中设置摄像机的 depthTextureMode 来完成
// 然后在 Shader 中通过声明 _CameraDepthTexture 变量来访问它
camera.depthTextureMode = DepthTextureMode.Depth;
// 获取深度+法线纹理
// 然后在 Shader 中通过声明 _CameraDepthNormalsTexture 变量来访问它
camera.depthTextureMode = DepthTextureMode.DepthNormals;

// 使用内置宏对深度纹理进行采样
float d = SAMPLE_DEPTH_TEXTURE (_CameraDepthTexture, i.uv);
float d = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos));
```

> 非线性深度值转换为线性的深度值

- 辅助函数 `LinearEyeDepth` 把深度纹理的采样结果转换到**视角空间**下的深度值(内部使用了内置的 `_ZBufferParams` 变量来得到远近裁剪平面的距离)
- 辅助函数 `Linear01Depth` 返回一个范围在 `[0, 1]` 的线性深度值(内部使用了内置的 `_ZBufferParams` 变量来得到远近裁剪平面的距离)
- 辅助函数 `DecodeDepthNormal` 用于对 `tex2D` 函数对 `_CameraDepthNormalsTexture` 进行采样得到的结果进行解码，从而得到**深度值**(范围在 `[0, 1]` 的线性深度值)和**法线方向**(视角空间下的法线方向)。也可以通过调用 `DecodeFloatRG` 和 `DecodeViewNormalStereo` 来解码深度+法线纹理中的深度和法线信息。

### 速度缓冲实现运动模糊

模拟运动模糊效果中的更加广泛应用的技术是使用**速度映射图**，速度映射图中存储了每个**像素的速度**，然后使用这个速度来决定模糊的方向和大小。

#### 速度缓冲的生成方法

- 把场景中所有物体的速度渲染到一张纹理中(缺点：需要修改场景中所有物体的 Shader 代码，使其添加计算速度的代码并输出到一个渲染纹理中)
- 利用**深度纹理**在片元着色器中为每个像素计算其在世界空间下的位置(通过使用当前的`视角*投影矩阵`的逆矩阵对 NDC 下的顶点坐标进行变换得到)。使用前一帧的`视角*投影矩阵`对其进行变换，得到该位置在前一帧中的 NDC 坐标。然后计算前一帧和当前帧的位置差，生成该像素的速度(优点：可以在一个屏幕后处理步骤中完成整个效果的模拟；缺点：需要在片元着色器中进行两次矩阵乘法的操作，对性能有所影响)

_**深度纹理模拟运动模糊**_

适用于场景静止、摄像机快速运动的情况。快速移动的物体产生运动模糊的效果，需要生成更加精确的速度映射图，Unity 自带的 `ImageEffect` 包含了更多实现方法。

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase {
  public Shader motionBlurShader;
  private Material motionBlurMaterial = null;
  public Material material {
    get {
      motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
      return motionBlurMaterial;
    }
  }
  [Range(0.0f, 1.0f)]
  public float blurSize = 0.5f;
  // 用于得到摄像机的视角和投影矩阵
  private Camera myCamera;
  public Camera camera {
    get {
      if(null == myCamera) {
        myCamera = GetComponent<Camera>();
      }
      return myCamera;
    }
  }
  // 保存上一帧摄像机的视角*投影矩阵
  private Matrix4x4 previousViewProjectionMatrix;

  void OnEnable() {
    // 设置摄像机的状态(获取摄像机的深度纹理)
    camera.depthTextureMode |= DepthTextureMode.Depth;
  }

  void OnRerderImage(RenderTexture src, RenderTexture dest) {
    if(null != material) {
      material.SetFloat("_BlurSize", blurSize);
      material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
      Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
      // 当前帧的视角*投影矩阵的逆矩阵
      Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
      material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
      previousViewProjectionMatrix = currentViewProjectionMatrix;
      Graphics.Blit(src, dest, material);
    } else {
      Graphics.Blit(src, dest);
    }
  }
}
```

```cs
Shader "Unlit/Chapter13-MotionBlurWithDepthTexture"
{
  Properties
  {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _BlurSize ("Bluer Size", Float) = 1.0
    // Unity 没有提供矩阵类型的属性，无法直接在这里声明
  }
  SubShader
  {
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    half4 _MainTex_TexelSize;
    // 由 Unity 传递的纹理
    sampler2D _CameraDepthTexture;
    // 由脚本传递的矩阵
    float4x4 _CurrentViewProjectionInverseMatrix;
    float4x4 _PreviousViewProjectionMatrix;
    half _BlurSize;

    struct v2f {
      float4 pos : SV_POSITION;
      half2 uv : TEXCOORD0;
      half2 uv_depth : TEXCOORD1;
    };

    v2f vert(appdata_img v) {
      v2f o;
      o.pos = UnityObjectToClipPos(v.vertex);
      o.uv = v.texcoord;
      o.uv_depth = v.texcoord;

      #if UNITY_UV_STARTS_AT_TOP
      // 处理渲染多张纹理时 DirectX 平台图像翻转问题
      if(_MainTex_TexelSize.y < 0) {
        o.uv_depth.y = 1 - o.uv_depth.y;
      }
      #endif

      return o;
    }

    fixed4 frag(v2f i) : SV_Target {
      // 获取当前像素的深度缓冲值(由 NDC 下的坐标映射得来)
      float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
      // 当前像素的 NDC 坐标 H，深度值重新映射回 NDC，范围均为 [-1, 1]
      float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
      // 使用当前帧的视角*投影矩阵的逆矩阵对 NDC 坐标进行变换，并把结果值除以它的 w 分量来得到世界空间下的坐标表示
      float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
      float4 worldPos = D / D.w;
      // 当前视角坐标
      float4 currentPos = H;
      // 使用前一帧的视角*投影矩阵对世界空间下的坐标进行变换，得到前一帧在 NDC 下的坐标
      float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
      // 得到取值 [-1, 1] 间的非线性点
      previousPos /= previousPos.w;

      // 计算前一帧和当前帧在屏幕空间下的位置差得到该像素的速度
      float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;
      // 使用速度值对它的邻域像素进行采样，相加后取平均值得到一个模糊的效果
      float2 uv = i.uv;
      float4 c = tex2D(_MainTex, uv);
      uv += velocity * _BlurSize; // _BlurSize 用于控制采样距离
      for(int it = 1; it < 3; it++, uv += velocity * _BlurSize) {
        float4 currentColor = tex2D(_MainTex, uv);
        c += currentColor;
      }
      c /= 3;
      return fixed4(c.rgb, 1.0);
    }
    ENDCG

    Pass {
      Ztest Always Cull Off ZWrite Off

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      ENDCG
    }
  }
  FallBack Off
}
```

### 基于屏幕后处理的全局雾效

Unity 内置的雾效可以产生基于距离的线性或指数雾效。要实现其他自定义的雾效需要使用 `#pragma multi_compile_fog` 指令，同时使用相关的内置宏如 `UNITY_FOG_COORDS`、`UNITY_TRANSFER_FOG` 和 `UNITY_APPLY_FOG` 等。然而使用这种方式可实现的效果非常有限。

> 基于屏幕后处理的全局雾效的关键是，根据深度纹理来重建每个像素在世界空间下的位置。主要有两种方式：

  1. 构建出当前像素的 NDC 坐标，再通过当前摄像机的视角*投影矩阵的逆矩阵来得到世界空间下的像素坐标(需要在片元着色器中进行矩阵乘法的操作，会影响游戏性能)
  2. 从深度纹理中重建世界坐标。首先对图像空间下的视锥体射线（从摄像机出发，指向图像上的某点的射线）进行插值，这条射线存储了该像素在世界空间下到摄像机的方向信息。然后把该射线和线性化后的视角空间下的深度值相乘，再加上摄像机的世界位置，就得到该像素在世界空间下的位置。

  ```cs
  float4 worldPos = _WorldSpaceCameraPos + linearDepth * interpolatedRay;
  ```

> 雾的计算

在简单的雾效实现中，需要计算一个雾效系数 `f`，作为混合原始颜色和雾的颜色的混合系数：

```cs
float3 afterFog = f * fogColor + (1 - f) * origColor;
```

Unity 内置的雾效实现中，支待三种雾的计算方式：

- 线性 Linear:
  `f = [d(max) - |z|]/[d(max) - d(min)]`,
  `d(min)` 和 `d(max)` 分别表示受雾影响的最小距离和最大距离.
- 指数 Exponential:
  `f = e^(-d·|z|)`,
  `d` 是控制雾的浓度的参数.
- 指数平方 Exponential Squared:
  `f = e^[(-d - |z|)^2]`

## 非真实感渲染

非真实感渲染学习书籍：『 艺术化绘制的图形学原理与方法 』

### 卡通风格渲染

实现卡通渲染有很多方法，其中之一是使用**基于色调的着色技术 (tone-based shading)**。在实现中，往往会使用漫反射系数对一张一维纹理进行采样，以控制漫反射的色调，模型的高光往往是一块块分界明显的纯色区域。卡通风格通常还需要在物体边缘部分绘制轮廓。

#### 渲染轮廓线

『 Real Time Rendering, third edition 』一书中把绘制模型轮廓线的方法分成了以下 5 种：

- 基于观察角度和表面法线的轮廓线渲染。

  这种方法使用视角方向和表面法线的点乘结果来得到轮廓线的信息。这种方法简单快速但同时局限性很大，很多模型渲染出来的描边效果往往不好。

- 过程式几何轮廓线渲染。

  这种方法的核心是使用两个 Pass 渲染。第一个 Pass 渲染背面的面片，并使用某些技术让它的轮廓可见；第二个 Pass 再正常渲染正面的面片。这种方法的优点在于快速有效，并且适用于绝大多数表面平滑的模型，但它的缺点是不适合类似于立方体这样平整的模型。

- 基于图像处理的轮廓线渲染。

  和实习边缘检测的方法属于同一类别。优点在于，可以适用于任何种类的模型。它的局限性在于一些深度和法线变化很小的轮廓无法被检测出来，例如桌子上的纸张。

- 基于轮廓边检测的轮廓线渲染。

  可以控制轮廓线的风格渲染。检测一条边是否是轮廓边的公式很简单，只需要检查和这条边相邻的两个三角面片是否满足条件 `(n0·v > 0) ≠ (n1·v > 0)`[n0 和 n1 分别表示两个相邻三角面片的法向，v 是从视角到该边上任意顶点的方向，本质在于检查两个相邻的三角面片是否一个朝正面、一个朝背面]。
  缺点是实现比较复杂，而且由于是逐帧单独提取轮廓，所以在帧与帧之间会出现跳跃性。

- 混合了上述的几种渲染方法。

#### 添加高光

在 Blinn-Phong 模型实现高光反射的过程中，使用法线点乘光照方向以及视角方向和的一半，再和另一个参数进行指数操作得到高光反射系数。

```cs
float spec = pow (max (0, dot(normal, halfDir)), _Gloss)
```

对于卡通渲染需要的高光反射光照模型，同样需要计算 normal 和 halfDir 的点乘结果，但不同的是，我们把该值和一个阈值进行比较，如果小于该阐值，则高光反射系数为 0, 否则返回 1。

```cs
float spec = dot(worldNormal, worldHalfDir);
// CG 的 step 函数接受两个参数，第一个参数是参考值，第二个参数是待比较的数值。如果第二个参数大于等于第一个参数，则返回 1，否则返回 0.
spec = step(threshold, spec);

// 使用 step 函数的判断方法会在高光区域的边界造成锯齿（高光区域的边缘不是平滑渐变的，而是由 0 突变到 1）
// 优化：smoothstep 函数
// w 是一个很小的值，当 spec - threshold 小于 -w 时，返回 0, 大于 w 时，返回1, 否则在 0 到 1 之间进行插值
spec = lerp(0, 1, smoothstep(-w, w, spec - threshold));
```

### 素描风格

微软研究院的[Praun等人](http://hhoppe.com/hatching.pdf)提出了使用提前生成的素描纹理来实现实时的素描风格渲染，这些纹理组成了一个**色调艺术映射(TonalArt Map, TAM)**。

![一个TAM的例子:从左到右纹理中的笔触逐渐增多，用于模拟不同光照下的漫反射效果，从上到下则对应了每张纹理的多级渐远纹理(mipmaps)](http://static.zybuluo.com/candycat/9h63lflg1a7f759pw5cwfqvz/TAM.png)

_**简化版实现：不考虑多级渐远纹理的生成**_

```cs
Shader "Unlit/Chapter14-Hatching"
{
  Properties
  {
    _Color ("Color Tint", Color) = (1, 1, 1, 1)
    // _TileFactor 是纹理的平铺系数，_TileFactor 越大，模型上的素描线条越密
    _TileFactor ("Tile Factor", Float) = 1
    _Outline ("Outline", Range(0, 1)) = 0.1
    // _Hatch0 至 _Hatch5 对应了渲染时使用的 6 张素描纹理，它们的线条密度依次增大
    _Hatch0 ("Hatch 0", 2D) = "white" {}
    _Hatch1 ("Hatch 1", 2D) = "white" {}
    _Hatch2 ("Hatch 2", 2D) = "white" {}
    _Hatch3 ("Hatch 3", 2D) = "white" {}
    _Hatch4 ("Hatch 4", 2D) = "white" {}
    _Hatch5 ("Hatch 5", 2D) = "white" {}
  }
  SubShader
  {
    Tags { "RenderType"="Opaque" "Quene"="Geometry" }

    // 获取轮廓线
    UsePass "Unlit/Chapter14-ToonShading/OUTLINE"

    Pass
    {
      Tags { "LightMode"="ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_fwdbase

      #include "UnityCG.cginc"
      #include "Lighting.cginc"
      #include "AutoLight.cginc"
      #include "UnityShaderVariables.cginc"

      fixed4 _Color;
      float _TileFactor;
      sampler2D _Hatch0;
      sampler2D _Hatch1;
      sampler2D _Hatch2;
      sampler2D _Hatch3;
      sampler2D _Hatch4;
      sampler2D _Hatch5;

      struct a2v {
        float4 vertex : POSITION;
        float4 tangent : TANGENT;
        float3 normal : NORMAL;
        float2 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        fixed3 hatchWeights0 : TEXCOORD1;
        fixed3 hatchWeights1 : TEXCOORD2;
        float3 worldPos : TEXCOORD3;
        SHADOW_COORDS(4)
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;

      v2f vert (a2v v)
      {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy * _TileFactor;

        fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
        fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
        // 漫反射系数
        fixed diff = saturate(dot(worldLightDir, worldNormal));

        o.hatchWeights0 = fixed3(0, 0, 0);
        o.hatchWeights1 = fixed3(0, 0, 0);

        // 把 diff 缩放到[0, 7] 范围
        float hatchFactor = diff * 7.0;

        // 把 [0, 7] 的区间均匀划分为 7 个子区间
        // 通过判断 batchFactor 所处的子区间来计算对应的纹理混合权重
        if (hatchFactor > 6.0) {
          // Pure white, do nothing
        } else if (hatchFactor > 5.0) {
          o.hatchWeights0.x = hatchFactor - 5.0;
        } else if (hatchFactor > 4.0) {
          o.hatchWeights0.x = hatchFactor - 4.0;
          o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
        } else if (hatchFactor > 3.0) {
          o.hatchWeights0.y = hatchFactor - 3.0;
          o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
        } else if (hatchFactor > 2.0) {
          o.hatchWeights0.z = hatchFactor - 2.0;
          o.hatchWeights1.x = 1.0 - o.hatchWeights0.z;
        } else if (hatchFactor > 1.0) {
          o.hatchWeights1.x = hatchFactor - 1.0;
          o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
        } else {
          o.hatchWeights1.y = hatchFactor;
          o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
        }

        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

        TRANSFER_SHADOW(o);

        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 对每张纹理进行采样并和它们对应的权重值相乘得到每张纹理的采样颜色
        fixed4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeights0.x;
        fixed4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeights0.y;
        fixed4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeights0.z;
        fixed4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeights1.x;
        fixed4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeights1.y;
        fixed4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeights1.z;
        // 计算纯白在渲染中的贡献度
        fixed4 whiteColor = fixed4(1, 1, 1, 1) * (1 - i.hatchWeights0.x - i.hatchWeights0.y - i.hatchWeights0.z -
              i.hatchWeights1.x - i.hatchWeights1.y - i.hatchWeights1.z);

        fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + whiteColor;

        UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

        return fixed4(hatchColor.rgb * _Color.rgb * atten, 1.0);
      }
      ENDCG
    }
  }
  Fallback "Diffuse"
}
```

## 噪声

### 实现消融效果

消融效果原理非常简单，概括来说就是**噪声纹理**+**透明度测试**。使用对噪声纹理采样的结果和某个控制消融程度的阈值比较，如果小于阈值，就使用 `clip` 函数把它对应的像素裁剪掉。

```cs
Shader "Unlit/Chapter15-Dissolve"
{
  Properties
  {
    // 控制消融程度
    _BurnAmount ("Burn Amount", Range(0.0,1.0)) = 0.0
    // 控制模拟烧焦效果时的线宽
    _LineWidth ("Burn Line Width", Range(0.0, 0.2)) = 0.1
    // 漫反射纹理
    _MainTex ("Base (RGB)", 2D) = "white" {}
    // 法线纹理
    _BumpMap ("Bump Map", 2D) = "white" {}
    // 火焰边缘的两种颜色值
    _BurnFirstColor ("Burn First Color", Color) = (1,0,0,1)
    _BurnSecondColor ("Burn Second Color", Color) = (1,0,0,1)
    // 噪声纹理
    _BurnMap ("Burn Map", 2D) = "white" {}
  }
  SubShader
  {
    Tags { "RenderType"="Opaque" "Queue"="Geometry"}

    Pass
    {
      Tags { "LightMode"="ForwardBase" }
      // 关闭该 Shader 的面片剔除，模型的正面和背面都会被渲染
      Cull Off

      CGPROGRAM

      #include "Lighting.cginc"
      #include "AutoLight.cginc"

      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_fwdbase

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float4 texcoord : TEXCOORD0;
      };
      struct v2f {
        float4 pos : SV_POSITION;
        float2 uvMainTex : TEXCOORD0;
        float2 uvBumpMap : TEXCOORD1;
        float2 uvBurnMap : TEXCOORD2;
        float3 lightDir : TEXCOORD3;
        float3 worldPos : TEXCOORD4;
        SHADOW_COORDS(5)
      };

      fixed _BurnAmount;
      fixed _LineWidth;
      sampler2D _MainTex;
      sampler2D _BumpMap;
      fixed4 _BurnFirstColor;
      fixed4 _BurnSecondColor;
      sampler2D _BurnMap;
      float4 _MainTex_ST;
      float4 _BumpMap_ST;
      float4 _BurnMap_ST;
      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        // 计算了三张纹理对应的纹理坐标
        o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
        o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
        o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

        TANGENT_SPACE_ROTATION;
        // 把光源方向从模型空间变换到了切线空间
          o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
          o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
          // 得到阴影信息
          TRANSFER_SHADOW(o);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        // 对噪声纹理进行采样
        fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
        // 将采样结果和属性 _BurnAmount 相减传递给 clip（当结果小于 0 时，该像素将会被剔除）
        clip(burn.r - _BurnAmount);

        float3 tangentLightDir = normalize(i.lightDir);
        fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

        // 材质的反射率
        fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;
        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
        fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

        // 在宽度为 _LineWidth 的范围内模拟一个烧焦的颜色变化
        fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
        fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
        // pow 只是让效果更接近烧焦的痕迹
        burnColor = pow(burnColor, 5);

        UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
        fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));

        return fixed4(finalColor, 1);
      }
      ENDCG
    }
    // 用于投射阴影的 Pass（使用透明度测试的物体的阴影需要特别处理）
    Pass {
      Tags { "LightMode" = "ShadowCaster" }
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #include "UnityCG.cginc"
      fixed _BurnAmount;
      sampler2D _BurnMap;
      float4 _BurnMap_ST;
      struct v2f {
        V2F_SHADOW_CASTER;
        float2 uvBurnMap : TEXCOORD1;
      };
      v2f vert(appdata_base v) {
        v2f o;
        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;

        clip(burn.r - _BurnAmount);

        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }
  }
}
```

### 实现水波效果

模拟水波效果时，噪声纹理通常会用作一个**高度图**，以不断修改水面的法线方向。为了模拟水不断流动的效果，使用和**时间相关**的变量来对噪声纹理进行采样，当得到法线信息后，再进行正常的反射+折射计算，得到最后的水面波动效果。

```cs
Shader "Unlit/Chapter15-WaterWaveMat"
{
  Properties {
    _Color ("Main Color", Color) = (0, 0.15, 0.115, 1)
    // 水面波纹材质纹理
    _MainTex ("Base (RGB)", 2D) = "white" {}
    // 由噪声纹理生成的法线纹理
    _WaveMap ("Wave Map", 2D) = "bump" {}
    // 用于模拟反射的立方体纹理
    _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
    // 用于控制法线纹理在 X 和 Y 方向上的平移速度
    _WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01
    _WaveYSpeed ("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01
    // 用于控制模拟折射时图像的扭曲程度
    _Distortion ("Distortion", Range(0, 100)) = 10
  }
  SubShader {
    // We must be transparent, so other objects are drawn before this one.
    Tags { "Queue"="Transparent" "RenderType"="Opaque" }

    // 获取屏幕图像
    // This pass grabs the screen behind the object into a texture.
    // We can access the result in the next pass as _RefractionTex
    GrabPass { "_RefractionTex" }

    Pass {
      Tags { "LightMode"="ForwardBase" }

      CGPROGRAM

      #include "UnityCG.cginc"
      #include "Lighting.cginc"

      #pragma multi_compile_fwdbase

      #pragma vertex vert
      #pragma fragment frag

      fixed4 _Color;
      sampler2D _MainTex;
      float4 _MainTex_ST;
      sampler2D _WaveMap;
      float4 _WaveMap_ST;
      samplerCUBE _Cubemap;
      fixed _WaveXSpeed;
      fixed _WaveYSpeed;
      float _Distortion;
      // 对应了在使用 GrabPass 时，指定的纹理名称
      sampler2D _RefractionTex;
      float4 _RefractionTex_TexelSize;

      struct a2v {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float4 texcoord : TEXCOORD0;
      };

      struct v2f {
        float4 pos : SV_POSITION;
        float4 scrPos : TEXCOORD0;
        float4 uv : TEXCOORD1;
        float4 TtoW0 : TEXCOORD2;  
        float4 TtoW1 : TEXCOORD3;  
        float4 TtoW2 : TEXCOORD4;
      };

      v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);

        o.scrPos = ComputeGrabScreenPos(o.pos);

        o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
        o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
        fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
        fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
        fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

        o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
        o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
        o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

        return o;
      }

      fixed4 frag(v2f i) : SV_Target {
        float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
        fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
        float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);

        // Get the normal in tangent space
        fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
        fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
        fixed3 bump = normalize(bump1 + bump2);

        // Compute the offset in tangent space
        float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
        // (*i.scrPos.z )模拟深度越大、折射程度越大的效果
        i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
        // 透视除法 _RefractionTex采样
        fixed3 refrCol = tex2D( _RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;

        // Convert the normal to world space
        bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
        fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
        fixed3 reflDir = reflect(-viewDir, bump);
        fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb * _Color.rgb;

        fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
        fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);

        return fixed4(finalColor, 1);
      }

      ENDCG
    }
  }
  // Do not cast shadow
  FallBack Off
}
```

### 全局雾效

在[基于屏幕后处理的全局雾效](#基于屏幕后处理的全局雾效)的基础上应用噪声模拟不均匀动态雾效

## Unity中的渲染优化技术

### 优化技术基础

#### 移动平台与 PC 平台

和 PC 平台相比，移动平台上的 GPU 架构有很大的不同。由于处理资源等条件的限制，移动设备上的 GPU 架构专注于尽可能使用更小的带宽和功能，也由此带来了许多和 PC 平台完全不同的现象。

由于这些芯片架构造成的不同，一些游戏往往需要针对不同的芯片发布不同的版本，以便对每个芯片进行更有针对性的优化。

对于一个游戏来说， 它主要需要使用两种计算资源：CPU 和 GPU。它们会互相合作， 来让我们的游戏可以在预期的帧率和分辨率下工作。其中，CPU 主要负责保证帧率，GPU 主要负责分辨率相关的一些处理。

#### 影响因素

CPU 因素

- 过多的 draw call。
- 复杂的脚本或者物理模拟。

GPU 因素

- 顶点处理。
  - 过多的顶点。
  - 过多的逐顶点计算。
- 片元处理。
  - 过多的片元（既可能是由于分辨率造成的，也可能是由于 overdraw 造成的）。
  - 过多的逐片元计算。
带宽因素

- 使用了尺寸很大且未压缩的纹理。

#### 针对 CPU 和 GPU 的优化

CPU 优化

- 使用批处理技术减少drawcall数目。

GPU 优化

- 减少需要处理的顶点数目。
  - 优化几何体。
  - 使用模型的 LOD (Level ofDetail) 技术。
  - 使用遮挡剔除(OcclusionCulling)技术。
- 减少需要处理的片元数目。
  - 控制绘制顺序。
  - 警惕透明物体。
  - 减少实时光照。
- 减少计算复杂度。
  - 使用Shader的LOD(Level of Detail)技术。
  - 代码方面的优化。

节省内存带宽

- 减少纹理大小。
- 利用分辨率缩放。

#### 分析工具

- 渲染统计窗口(RenderingStatistics Window)
- 性能分析器(Profiler)
- 帧调试器(Frame Debugger)
- 高通的 Adreno 分析工具
- 英伟达的 NVPerfHUD 工具
- PowerVRAM 的 PVRUniSCo shader 分析器
- Xcode 中的 OpenGL ES Driver Instruments

### 减少 draw call 数目

#### 批处理

- 尽可能选择静态批处理，但得时刻小心对内存的消耗，并且记住经过静态批处理的物体不可以再被移动。
- 如果无法进行静态批处理，而要使用动态批处理的话，要小心各种条件限制。例如，尽可能让这样的物体少并且尽可能让这些物体包含少蜇的顶点属性和顶点数目。
- 对于游戏中的小道具，例如可以捡拾的金币等，可以使用动态批处理。
- 对于包含动画的这类物体，我们无法全部使用静态批处理，但其中如果有不动的部分，可以把这部分标识成 "Static"。
- 批处理需要把多个模型变换到世界空间下再合并它们，因此，如果 shader 中存在基于模型空间下的坐标的运算，那么往往会得错误的结果(一个解决方法是，在shader中使用`DisableBatching`标签来强制使用该Shader的材质不会被批处理)。
- 使用半透明材质的物体通常需要使用严格的从后往前的绘制顺序来保证透明混合的正确性。当绘制顺序无法满足时，批处理无法在这些物体上被成功应用。

##### 动态批处理

动态批处理的基本原理是，每一帧把可以进行批处理的模型网格进行合并，再把合并后模型数据传递给GPU, 然后使用同一个材质对其渲染。如果场景中的一些模型共享了**同个材质**并满足一些条件，Unity就可以**自动**把它们进行批处理，从而只需要花费一个draw call 就可以渲染所有的模型。

优点：一切处理都是Unity自动完成的，不需要自己做任何操作，而且物体是可以移动（在处理每帧时Unity都会重新合并一次网格）的。

缺点：只有满足条件的模型和材质才可以被动态批处理。

- 能够进行动态批处理的网格的顶点属性规模要小于900。
- (Unity5 之前)一般来说，所有对象都需要使用同一个缩放尺度。
- 使用光照纹理(lightmap)的物体需要小心处理。这些物体需要额外的渲染参数，例如，在光照纹理上的索引、偏移量和缩放信息等。因此，为了让这些物体可以被动态批处理，我们需要保证它们指向光照纹理中的同一位置。
- 多 Pass 的 shader 会中断批处理。

##### 静态批处理

静态批处理实现原理是，只在运行开始阶段，把需要进行静态批处理的模型合并到一个新的网格结构中，这意味着这些模型不可以在运行时刻被移动。

优点：任何大小的几何模型。只需要进行一次合并操作，因此，比动态批处理更加高效。

缺点：不可以在运行时刻被移动。往往需要占用更多的内存来存储合并后的几何结构(如果在静态批处理前一些物体共享了相同的网格，那么在内存中每一个该网格的复制)。

##### 共享材质

- 如果两个材质之间只有使用的纹理不同，我们可以把这些纹理合并到一张更大的纹理中，这张更大的纹理被称为是一张**图集(atlas)**。一旦使用了同一张纹理，就可以使用同 个材质，再使用不同的采样坐标对纹理采样。
- 即使纹理相同，不同的物体在材质上还有参数变化(颜色、浮点属性等)，这些参数调整可以**使用网格的顶点数据（最常见的就是顶点颜色数据）来存储**。

### 减少需要处理的顶点数目

#### 优化几何体

在建模时要尽可能减少模型中三角面片的数目，对于模型没有影响、或是肉眼非常难察觉到区别的顶点都要尽可能去掉。并且移除不必要的硬边以及纹理衔接，避免边界平滑和纹理分离。

#### 模型的 LOD 技术

这种技术的原理是，当一个物体离摄像机很远时，模型上的很多细节是无法被察觉到的。因此，LOD 允许当对象逐渐远离摄像机时，减少模型上的面片数量，从而提高性能。在Unity中，使用 LOD Group 组件来为物体构建个 LOD。需要为同一个对象准备多个包含不同细节程序的模型，然后把它们赋给 LOD Group 组件中的不同等级，Unity 就会自动判断当前位置上需要使用哪个等级的模型。

#### 遮挡剔除技术

遮挡剔除可以用来消除那些在其他物件后面看不到的物件，这意味着资源不会浪费在计算那些看不到的顶点上，进而提升性能。

遮挡剔除会使用一个虚拟的摄像机来遍历场景，从而构建一个潜在可见的对象集合的层级结构。在运行时，每个摄像机将会使用这个数据来识别哪些物体是可见的，而哪些被其他物体挡住不可见。使用遮挡剔除技术，不仅可以减少处理的顶点数目，还可以减少 over draw, 提高游戏性能。

### 减少需要处理的片元数目

优化的重点在于减少 overdraw(同一个像素被绘制了多次)。

#### 控制绘制顺序

为了最大限度地避免 overdraw, 一个重要的优化策略就是**控制绘制顺序**。由于深度测试的存在，如果我们可以保证物体都是从前往后绘制的，那么就可以很大程度上减少overdraw。这是因为，在后面绘制的物体由于无法通过深度测试，因此，就不会再进行后面的渲染处理。

**尽可能地把物体的渲染队列设置为不透明物体的渲染队列，尽量避免使用半透明队列**。在Unity中，那些渲染队列数目小于 2500 (如 `Background`,`Geometry`和`AlphaTest`) 的对象都被认为是不透明(`opaque`)的物体，这些物体总体上是从前往后绘制的，而使用其他的队列（如`Transparent`,`Overlay`等）的物体，则是从后往前绘制的。

> 可以充分利用 Unity 的渲染队列来控制绘制顺序。排序思想：

- 在第一人称射击游戏中，对于游戏中的主要人物角色来说，他们使用的 shader 往往比较复杂，但是，由于他们通常会挡住屏幕的很大部分区域，因此我们可以先绘制它们（使用更小的渲染队列）。
- 敌方角色通常会出现在各种掩体后面，因此可以在所有常规的不透明物体后面渲染它们（使用更大的渲染队列 ）。
- 天空盒子几乎覆盖了所有的像素，而且它永远会出现在所有物体的后面，因此它的队列可以设置为`Geometry+1`，这样可以保证不会因为它而造成 overdraw。

#### 注意透明物体

半透明对象没有开启深度写入，因此要得到正确的渲染效果，就必须从后往前渲染。这意味着，半透明物体几乎一定会造成 overdraw。在一些机器上可能会造成严重的性能下降。如果场景中包含了大面积的半透明对象，或者有很多层相互重盖的半透明对象（即便它们每个的面积可能都不大），或者是透明的粒子效果，在移动设备上也会造成大量的 overdraw。

针对 GUI 对象(都是半透明的)，应该尽量减少窗口中 GUI 所占的面积，把 GUI 的绘制和三维场景的绘制交给不同的摄像机，而其中负责三维场景的摄像机的视角范围尽量不要和 GUI 的相互重叠。

在移动平台上，透明度测试也会影响游戏性能。虽然透明度测试没有关闭深度测试，但由于
它的实现使用了 `discard` 或 `clip` 操作，而这些操作会导致一些硬件的优化策略失效。这种时候，使用透明度混合的性能往往比使用透明度测试更好。

#### 减少实时光照和阴影

实时光照对于移动平台是一种非常昂贵的操作。如果场景中包含了过多的点光源，并且使用了多个 Pass 的 Shader，那么很有可能会造成性能下降。在移动平台上，一个物体使用的逐像素光源数目应该小于 1 (不包括平行光）。如果一定要使用更多的实时光，可以选择用逐顶点光照来代替。

模拟光源减少阴影：

- 使用烘焙技术，把光照提前烘焙到一张光照纹理 (lightmap)中，然后在运行时刻只需要根据纹理采样得到光照结果。
- 使用 God Ray。很多小型光源的效果一般并不是真的光源，很多情况是通过透明纹理模拟得到的。
- 使用烘焙把静态物体的阴影信息存储到光照纹理中，而只对场景中的动态物体使用适当的实时阴影。

### 节省带宽

大量使用未经压缩的纹理以及使用过大的分辨率都会造成由于带宽而引发的性能瓶颈。

#### 减少纹理大小

- 纹理的大小需要考虑，纹理的长宽比最好是正方形，长宽值最好是2的整数幕。
- 尽可能使用多级渐远纹理技术(mipmapping)和纹理压缩。

#### 利用分辨率缩放

在 Unity 中设置屏幕分辨率。

### 减少计算复杂度

#### Shader 的 LOD 技术

Shader 的 LOD 技术可以控制使用的 Shader 等级。它的原理是，只有 Shader 的 LOD 值小于某个设定的值，这个 Shader 才会被使用，而使用了那些超过设定值的 Shader 的物体将不会被渲染。

在默认情况下，允许的 LOD 等级是无限大的。这意味着，任何被当前显卡支持的 Shader 都可以被使用。但是，在某些情况下可能需要去掉一些使用了复杂计算的 Shader 渲染。这时，我们可以使用 `Shader.maximumLOD` 或 `Shader.glob alMaximumLOD` 来设置允许的最大 LOD 值。

```cs
SubShader {
  Tags { "RenderType"="Opaque" }
  LOO 200
}
```

#### 代码相关优化

通常来讲，游戏需要计算的对象、顶点和像素的数目排序是对象数 < 顶点数 < 像素数。因此，我们应该尽可能地把计算放在每个对象或逐顶点上。

具体的代码编写上，不同的硬件甚至需要不同的处理。

- 尽可能使用低精度的浮点值进行运算。最高精度的 `float/highp` 适用于存储诸如顶点坐标等变量，但它的计算速度是最慢的。`half/mediump` 适用于一些标量、纹理坐标等变量，它的计算速度大约是 `float` 的两倍。`fixed/lowp` 适用于绝大多数颜色变盐和归一化后的方向矢量，在进行一些对精度要求不高的计算时，应该尽量使用这种精度的变量。它的计算速度大约是 `float` 的 4 倍，但要避免对这些低精度变量进行频繁的 `swizzle` 操作（如 `color.xwxw`)。还需要注意的是，应当尽量避免在不同精度之间的转换，这有可能会造成一定的性能下降。
- 对于绝大多数 GPU 来说，在使用插值寄存器把数据从顶点着色器传递给下一个阶段时，我们应该使用尽可能少的插值变量。
- 尽可能不要使用全屏的屏幕后处理效果。如果美术风格实在是需要使用类似 Bloom、热扰动这样的屏幕特效，应该尽量使用 `fixed/lowp` 进行低精度运算（纹理坐标除外， 可以使用half/mediump)。那些高精度的运算可以使用查找表 (LUT) 或者转移到顶点着色器中进行处理。除此之外，尽量把多个特效合并到一个 Shader 中。
- 尽可能不要使用分支语句和循环语句。
- 尽可能避免使用类似 `sin`、`tan`、`pow`、`log` 等较为复杂的数学运算。我们可以使用查找表来作为替代。
- 尽可能不要使用 `discard` 操作，因为这会影响硬件的某些优化。

#### 根据硬件条件进行缩放

根据设备硬件性能的不同启用不同的分辨率、特效等。

## 表面着色器

### 编译指令

`#pragma surface` 用于指明该编译指令是用于定义表面着色器的，在它的后面需要指明使用的表面函数(`surfaceFunction`)和光照模型(`lightModel`)，同时，还可以使用一些可选参数来控制表面着色器的一些行为。

#### 表面函数

一个对象的表面属性定义了它的反射率、光滑度、透明度等值。而编译指令中的 `surfaceFunction` 就用于定义这些表面属性。`surfaceFunction` 通常就是名为  `surf` 的函数（函数名可以是任意的），它的函数格式是固定的：

```cs
// 输入结构体 Input IN 来设置各种表面属性
// 并把这些属性存储在输出结构体 SurfaceOutput、SurfaceOutputStandard或SurfaceOutputStandardSpecular中
// 再传递给光照函数计算光照结果
void surf(Input IN, inout SurfaceOutput o)
void surf(Input IN, inout SurfaceOutputStandard o)
void surf(Input IN, inout SurfaceOutputStandardSpecular o)
```

#### 光照函数

光照函数会使用表面函数中设置的各种表面属性，来应用某些光照模型，进而模拟物体表面的光照效果。

Unity 内置了基于物理的光照模型函数 `Standard` 和 `StandardSpecular` (在 `UnityPBSLighting.cginc` 文件中被定义），以及简单的非基于物理的光照模型函数 `Lambert` 和 `BlinnPhoog` (在 `Lighting.cginc` 文件中被定义）。

[Custom lighting models in Surface Shaders](https://docs.unity3d.com/Manual/SL-SurfaceShaderLighting.html)

#### 可选参数

可选参数包含了很多非常有用的指令类型，例如，开启/设置透明度混合/透明度测试，指明自定义的顶点和颜色修改函数，控制生成的代码等。

- 自定义的修改函数。
  除了表面函数和光照模型外，表面着色器还可以支持其他两种自定义的函数：**顶点修改函数**(`vertex:VertexFunction`) 和**最后的颜色修改函数**(`finalcolor:ColorFunction`)。顶点修改函数允许我们自定义顶点属性，例如，把顶点颜色传递给表面函数，或是修改顶点位置，实现某些顶点动画等。最后的颜色修改函数则可以在颜色绘制到屏幕前，最后一次修改颜色值，例如实现自定义的雾效等。
- 阴影。
  可以通过一些指令来控制和阴影相关的代码。例如 `addshadow` 参数会为表面着色器生成一个阴影投射的 Pass。`fullforwardshadows` 参数则可以在前向渲染路径中支待所有光源类型的阴影。`noshadow` 参数用来禁用阴影。
- 透明度混合和透明度测试。
  可以通过 `alpha` 和 `alphatest` 指令来控制透明度混合和透明度测试。例如，`alphatest:VariableName` 指令会使用名为 `VariableName` 的变量来剔除不满足条件的片元。
- 光照。
  一些指令可以控制光照对物体的影响。`noambient` 参数会告诉 Unity 不要应用任何环境光照或光照探针(light probe)。`novertexlights` 参数告诉 Unity 不要应用任何逐顶点光照。`noforwardadd` 会去掉所有前向渲染中的额外的 Pass。`nolightmap`、`nofog` 用于控制光照烘焙、雾效模拟。
- 控制代码的生成。
  一些指令还可以控制由表面着色器自动生成的代码。如 `exclude_path:deferred`、`exclude_path:forward`和`exclude_path :prepass` 制定不需要为某些渲染路径生成代码。

### 结构体 Input 和 SurfaceOutput

一个表面着色器需要使用两个结构体：表面函数的输入结构体 `Input`, 以及存储了表面属性 的结构体 `SurfaceOutput` (Unity 5 新引入了另外两个同种的结构体 `SurfaceOutputStandard` 和 `SurfaceOutputStandardSpecular`)。

#### Input 结构体

`Input` 结构体包含了许多**表面属性**的数据来源，因此，它会作为表面函数的输入结构体（如果自定义了顶点修改函数，它还会是顶点修改函数的输出结构体）。`Input` 支持很多内置的变量名，通过这些变量名，我们告诉 Unity 需要使用的数据信息。一个例外情况是，自定义了顶点修改函数，并需要向表面函数中传递自定义的数据，这需要在顶点修改函数中自行计算相关参数。

_**Input 结构体中内置的变量**_

| 变量 | 描述 |
| --- | ----|
| `float2 uv_MainTex` | 包含了主纹理的采样坐标 |
| `float2 uv_BumpMap` | 包含了法线纹理的采样坐标 |
| `float3 viewDir` | 包含了视角方向，可用于计算边缘光照等 |
| 使用 `COLOR` 语义定义的 `float4` 变量 | 包含了插值后的逐顶点颜色 |
| `float4 screenPos` | 包含了屏幕空间的坐标，可以用于反射或屏幕特效 |
| `float3 worldPos` | 包含了世界空间下的位置 |
| `float3 worldRefl` | 包含了世界空间下的反射方向。前提是没有修改表面法线`o.Normal` |
| `float3 worldRefl; INTERNAL_DATA`  | 如果修改了表面法线 `o.Normal`, 需要使用该变量告诉 Unity 要基于修改后的法线计算世界空间下的反射方向。在表面函数中，我们需要使用 `WorldReflectionVector(IN, o.Normal)` 来得到世界空间下的反射方向 |
| `float3 worldNormal` | 包含了世界空间的法线方向。前提是没有修改表面法线`o.Normal` |
| `float3 worldNormal; INTERNAL_DATA` | 如果修改了表面法线 `o.Normal`, 需要使用该变量告诉Unity要基于修改后的法线计算世界空间下的法线方向。在表而函数中，我们需要使用 `WorldNormalVector(IN, o.Normal)` 来得到世界空间下的法线方向 |

#### SurfaceOutput 结构体

`SurfaceOutput`、`SurfaceOutputStandard` 和 `SurfaceOutputStandardSpecular` 结构体用于存储表面属性, 它会作为表面函数的输出，随后会作为光照函数的输入来进行各种光照计算。这个结构体里面的变量是提前就声明好的，不可以增加也不会减少。

如果使用了非基于物理的光照模型(`Lambert` 和 `BlinnPhong`)，我们通常会使用 `SurfaceOutput` 结构体， 而如果使用了基于物理的光照模型 `Standard` 或 `StandardSpecular`，会分别使用 `SurfaceOutputStandard` 或 `SurfaceOutputStandardSpecular` 结构体。

`SurfaceOutputStandard` 结构体用于默认的金属工作流程(Metallic Workflow)，对应了 `Standard` 光照函数
`SurfaceOutputStandardSpecuJar` 结构体用于高光工作流程(Specular Workflow)，对应了 `StandardSpecular` 光照函数。

```cs
struct SurfaceOutput {
  fixed3 Albedo; // 对光源的反射率。通常由纹理采样和颜色属性的乘积计算而得。
  fixed3 Normal; // 表面法线方向。
  fixed3 Emission; // 自发光。
  half Specular; // 高光反射中的指数部分的系数，影响高光反射的计算。
  fixed Gloss; // 高光反射中的强度系数
  fixed Alpha; // 透明通道。
};

struct SurfaceOutputStandard {
  fixed3 Albedo; // base (diffuse or specular) color
  fixed3 Normal; // tangent space normal, if written
  half3 Emission;
  half Metallic; // 0=non-metal, 1=metal
  half Smoothness; // 0=rough, 1=smooth
  half Occlusion; // occlusion(default 1)
  fixed Alpha; // alpha for transparencies
};

struct SurfaceOutputStandardSpecular {
  fixed3 Albedo; // diffuse color
  fixed3 Specular; // specular color
  fixed3 Normal; // tangent space normal, if written
  half3 Emission;
  half Smoothness; // 0=rough, 1=smooth
  half Occlusion; // occlusion(default 1)
  fixed Alpha; // alpha for transparencies
};
```

### surface shader 的缺点

- 表面着色器虽然可以快速实现各种光照效果，但我们失去了对各种优化和各种特效实现的控制。因此，使用表面着色器往往会对性能造成一定的影响。
- 表面着色器无法完成一些自定义的渲染效果，如透明玻璃的效果。

使用建议：

- 如果需要和各种光源打交道，尤其是想要使用 Unity 中的全局光照的话，使用表面着色器更加方便，但需要注意性能问题。
- 如果需要处理的光源数目非常少，使用顶点/片元着色器是更好的选择。
- 如果有很多自定义的渲染效果，则选择顶点/片元着色器。

## 基于物理的渲染

Lambert 光照模型、Phong 光照模型和 Blinn-Phong 光照模型都是经验模型。如果需要渲染更高质址的画面，这些经验模型不再能满足要求。因此另一种技术 —— **基于物理的渲染技术(Physically Based Shading, PBS)** 被逐渐应用于实时渲染中。PBS是为了对光和材质之间的行为进行更加真实的建模。

### 双向反射分布函数 (BRDF)

