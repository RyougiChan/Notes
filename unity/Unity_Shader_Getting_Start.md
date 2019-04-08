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
  
  可以对两个矢雇进行相加【三角形定则(triangle rule)】或相减，其结果是一个相同维度的新矢量。只需要把两个矢量的对应分批进行相加或相减即可。
  
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
        fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;

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