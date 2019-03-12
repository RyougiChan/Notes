# Unity Notes

## [Shaders: ShaderLab 和 固定渲染管线 shaders](https://docs.unity3d.com/Manual/ShaderTut1.html)

### Shader 入门其之一

- 创建新 shader：
主菜单依次选择 `Assets > Create > Shader > Unlit Shader`。
- 编辑 shader：
Unity 可以使用 `fixed-function` 标记来编写 shaders（在内部，fixed-function shader 在导入 shader 时转换为常规的 [vertex and fragment programs](https://docs.unity3d.com/Manual/SL-ShaderPrograms.html)。）。写入如下内容：

```csharp
Shader "Tutorial/Basic" {
    // 在属性块中，我们可以传递一些自定义数据。
    Properties {
        _Color ("Main Color", Color) = (1,0.5,0.5,1)
    }
    SubShader {
        // 调用 Pass 来渲染对象(每个 SubShader 至少有一个 Pass 语句块)
        Pass {
            // 将漫反射材质组件设置为属性 _Color
            Material {
                Diffuse [_Color]
            }
            // 打开每个顶点光照(per-vertex lighting)。
            Lighting On
        }
    }
}
```

- 使用该 shader：
创建新材质(Material)，从下拉菜单中选择 Shader(Tutorial > Basic) 并将材质指定给某个对象。调整 Material Inspector 中的颜色。

### Shader 解析(以内置 VertexLit shader 为例)

VertexLit shader 配置标准顶点光照并设置纹理组合器，以便渲染的光照强度加倍。

- 源码

```csharp
// Shader: 所有 shader 都以关键字 Shader 开头
// "VertexLit": Shader 名称，使用斜杠 / 可将 Shader 放在子菜单中，如 `MyShaders/Test`
Shader "VertexLit" {
    // Properties: 定义一系列属性
    // 我们在这里声明的数据将被显示在 Unity Editor 面板中，在 Editor 中更改也会驱动脚本更改。
    // 属性声明：内部属性名称 ("Inspector 显示标题", 属性类型) = 默认值
    Properties {
        _Color ("Main Color", Color) = (1,1,1,0.5)
        _SpecColor ("Spec Color", Color) = (1,1,1,1)
        _Emission ("Emmisive Color", Color) = (0,0,0,0)
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
        _MainTex ("Base (RGB)", 2D) = "white" { }
    }

    // 每一个 Shader 有一个或者多个 SubShader
    // 当 Unity 渲染 Shader 时，它将遍历所有 SubShader 并使用硬件支持的第一个着色器。该系统允许 Unity 支持所有现有硬件并最大限度地提高每个硬件的质量。
    SubShader {
        // 每个 SubShader 至少有一个 Pass 语句块，它实际上是对象渲染的位置。
        // 一些特效要求有多个 Pass 语句块
        Pass {
            // 我们的属性值绑定到固定渲染管线照明材质设置
            Material {
                Diffuse [_Color]
                Ambient [_Color]
                Shininess [_Shininess]
                Specular [_SpecColor]
                Emission [_Emission]
            }
            // 打开标准顶点照明
            Lighting On
            // 可以为镜面反射高光使用单独的颜色
            SeparateSpecular On
            /// 截止到这里上面的命令都非常直接映射到固定功能 OpenGL/Direct3D 硬件模型
            // SetTexture: 定义了我们想要使用的纹理以及如何在渲染中混合，组合和应用它们
            SetTexture [_MainTex] {
                // SetTexture 中的代码当渲染带屏幕上时对每个像素执行
                // 设置一个常数的颜色值，即材质的颜色
                constantColor [_Color]
                /// 另一种常用的组合模式称为 previous
                // Combine: 指定如何将纹理与另一个纹理或颜色混合，格式通常如  `Combine ColorPart, AlphaPart`
                // texture: 来自当前纹理的颜色
                // primary: 顶点照明颜色，根据上面的材料值(Material)计算
                // DOUBLE: 乘以 2 以增加照明强度
                // constant: 上面 constantColor 的值
                Combine texture * primary DOUBLE, texture * constant
            }
        }
        // 可选指令
        // 它指示程序在当前 Shader 中没有可以在用户的​​图形硬件上运行的 SubShaders 时应该使用哪个 Shader 来替代
        // FallBack "AnotherShader"
    }
}
```

## [Shaders: 顶点和片元编程](https://docs.unity3d.com/Manual/ShaderTut2.html)

### Shader 入门其之二

当使用顶点和片元程序（所谓的“可编程管线”）时，图形硬件中的大多数硬编码功能（“固定渲染管线”）都将被关闭。例如，使用顶点程序会完全关闭标准 3D 变换、光照和纹理坐标生成。编写顶点/片元程序需要全面了解 3D 变换、光照和坐标空间 - 因为必须自己重写内置于 OpenGL 等 API 的固定渲染。

以下示例演示了一个完整的 Shader，它将对象法线呈现为指定颜色：

```csharp
Shader "Tutorial/Display Normals" {
    // 在属性块中，我们可以传递一些自定义数据。
    // 我们在这里声明的数据将被显示在 Unity Editor 面板中，在Editor 中更改也会驱动脚本更改。
    // 要在 Cg/HLSL 中使用它们，只需定义匹配名称和类型的变量。
    Properties {
        // 声明格式 `name ("display name",type)=default value`
        // 颜色
        _Colour ("_Colour",Color) = (1,1,1,1)
        // 纹理贴图
        _MainTexture ("Mian Texture",2D) = "white"{}
        // 使用我们的噪音纹理，并实现一种“溶解”或“剪切”效果
        _DissolveTexture ("Dissolve Texture", 2D) = "white" {}
        _DissolveCutoff ("Dissolve Cutoff", Range(0, 1)) = 1

        _ExtrudeAmount ("Extrue Amount", float) = 0
    }
    SubShader {
        Pass {
            // 我们实际写的所有 Shader Cg/HLSL 代码都在 CGPROGRAM 和 ENDCG 中，对于 Unity 来说，shaderlab 是 HLSL 和 CG 的变体。
            CGPROGRAM
            // 告诉代码包含给定函数中的顶点程序（此处为 vert）
            #pragma vertex vert
            // 告诉代码包含给定函数中的片元程序（这里是 frag）
            #pragma fragment frag
            // UnityCG.cginc 文件包含常用的声明和函数
            #include "UnityCG.cginc"

            // 定义“顶点到片元”结构，命名为 v2f，包含从顶点传递给片元程序的信息
            struct v2f {
                // 传递位置和颜色参数。
                float4 pos : SV_POSITION;
                // 颜色将在顶点程序中计算，并在片元程序中输出。
                fixed3 color : COLOR0;
            };

            // Properties 中声明的变量需要在 CG/HLSL 代码中重新声明
            float4 _Colour;
            sampler2D _MainTexture;
            sampler2D _DissolveTexture;
            float _DissolveCutoff;
            float _ExtrudeAmount;

            // 定义顶点程序 - vert 函数
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // normal 组件取值在 -1~1 之间
                o.color = v.normal * 0.5 + 0.5;
                return o;
            }

            // 定义一个片元程序 - frag 函数
            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4 (i.color, 1);
            }
            ENDCG

        }
    }
}
```

### [编写顶点和片元着色器](https://docs.unity3d.com/Manual/SL-ShaderPrograms.html)

着色器程序是用 [HLSL(High-Level Shading Language)](https://docs.unity3d.com/Manual/SL-ShadingLanguage.html) 语言编写的，方法是在 Pass 命令中的某处着色器文本中嵌入“片段”

#### HLSL 片段

HLSL 程序片段是在 `CGPROGRAM` 和 `ENDCG`关键字之间编写的，或者在 `HLSLPROGRAM` 和 `ENDHLSL` 之间。后一种形式不会自动包含 `HLSLSupport` 和 `UnityShaderVariables` [内置头文件](https://docs.unity3d.com/Manual/SL-BuiltinIncludes.html)。每个片段必须至少包含一个顶点程序和一个片段程序。因此需要 `#pragma vertex` 和 `#pragma fragment` 指令。

- **内置着色器包含文件**

  Unity中的着色器包含文件扩展名为 `.cginc`，内置的文件为：
  - `HLSLSupport.cginc` （自动包含）跨平台着色器的编译提供程序宏与定义
  - `UnityShaderVariables.cginc` （自动包含）常用的全局变量
  - `UnityCG.cginc` 常用的辅助函数，通常包含在 Unity 着色器中
  UnityCG.cginc 中的数据结构
    - `appdata_base` 顶点着色器(vertex shader)输入位置，法线，一个纹理坐标
    - `appdata_tan` 顶点着色器(vertex shader)输入位置，法线，切线，一个纹理坐标
    - `appdata_full` 顶点着色器输入位置，法线，切线，顶点颜色和两个纹理坐标
    - `appdata_img` 顶点着色器输入位置和一个纹理坐标
  - `AutoLight.cginc` 照明和阴影功能，表面着色器在内部使用此文件
  - `Lighting.cginc` 标准表面着色器照明模型，编写表面着色器时自动包含
  - `TerrainEngine.cginc` 地形(Terrain)和植被着色器辅助函数

```csharp
CGPROGRAM
// 用法 #include ...
#include "UnityCG.cginc"
ENDCG
```

- 编译指令：`#pragma` 语句

  指示哪个着色器函数要编译
  - `#pragma vertex name` - 将函数 `name` 编译为顶点着色器
  - `#pragma fragment name` - 将函数 `name` 编译为片元着色器
  - `#pragma geometry name` - 将函数 `name` 编译为 DX10 几何着色器。拥有此选项会自动打开 `#pragma target 4.0`
  - `#pragma hull name` - 将函数 `name` 编译为 DX11 外壳着色器。拥有此选项会自动打开 `#pragma target 5.0`
  - `#pragma domain name` - 将函数 `name` 编译为 DX11 域着色器。拥有此选项会自动打开 `#pragma target 5.0`
  - `#pragma target name` - 指定[着色器编译目标级别](https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html)，要允许使用更现代的GPI功能，必须使用更高的着色器编译目标
  - `#pragma require feature ...` - 精确控制着色器所需的GPU
  - `#pragma only_renderers space separated names` - 仅为给定的渲染器编译着色器。默认情况下，为所有渲染器编译着色器
  - `#pragma exclude_renderers space separated names` - 不为给定的渲染器编译着色器。默认情况下，为所有渲染器编译着色器
  - `#pragma multi_compile ...` - 用于处理多个着色器变体
  - `#pragma enable_d3d11_debug_symbols` - 为 DirectX 11 编译的着色器生成调试信息，这将允许您通过 Visual Studio 2012（或更高版本）图形调试器调试着色器
  - `#pragma hardware_tier_variants renderer name` - 对于可以运行所选渲染器的每个硬件层，为每个编译的着色器生成多重着色器硬件变体
  - `#pragma hlslcc_bytecode_disassembly` - 将反汇编的 HLSLcc 字节码嵌入到已翻译的着色器中
  - `#pragma disable_fastmath` - 启用精确的 IEEE 754 规则，主要涉及 `NaN` 处理（目前仅影响 Metal 平台）
  - `#pragma glsl_es2` - 在 GLSL 着色器中设置时，即使着色器目标是 OpenGL ES 3，也会生成 GLSL ES 1.0（OpenGL ES 2.0）
  - `#pragma editor_sync_compilation` - 强制同步编译（仅影响编辑器）

#### 渲染平台

Unity 支持多种渲染  API（例如 Direct3D 11 和 OpenGL），默认情况下，所有着色器程序都编译到所有支持的渲染器中。可以使用 `#pragma only_renderers` 或 `#pragma exclude_renderers` 指令指示要编译的渲染器。

支持的渲染器名称:

- `d3d11` - Direct3D 11/12
- `glcore` - OpenGL 3.x/4.x
- `gles` - OpenGL ES 2.0
- `gles3` - OpenGL ES 3.x
- `metal` - iOS/Mac Metal
- `vulkan` - Vulkan
- `d3d11_9x` - Direct3D 11 9.x 功能级别，与 WSA 平台上常用的一样
- `xboxone` - Xbox One
- `ps4` - PlayStation 4
- `n3ds` - Nintendo 3DS
- `wiiu` - Nintendo Wii U