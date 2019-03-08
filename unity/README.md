# Unity Notes

## [Shaders: ShaderLab 和 固定渲染管线 shaders](https://docs.unity3d.com/Manual/ShaderTut1.html)

### 入门

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

## [Shaders: 顶点和片段程序](https://docs.unity3d.com/Manual/ShaderTut2.html)

当使用顶点和片段程序（所谓的“可编程管线”）时，图形硬件中的大多数硬编码功能（“固定渲染管线”）都将被关闭。例如，使用顶点程序会完全关闭标准 3D 变换、光照和纹理坐标生成。编写顶点/片段程序需要全面了解 3D 变换、光照和坐标空间 - 因为必须自己重写内置于 OpenGL 等 API 的固定渲染。

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
            // 告诉代码包含给定函数中的片段程序（这里是 frag）
            #pragma fragment frag
            // UnityCG.cginc 文件包含常用的声明和函数
            #include "UnityCG.cginc"

            // 定义“顶点到片段”结构，命名为 v2f，包含从顶点传递给片段程序的信息
            struct v2f {
                // 传递位置和颜色参数。
                float4 pos : SV_POSITION;
                // 颜色将在顶点程序中计算，并在片段程序中输出。
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

            // 定义一个片段程序 - frag 函数
            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4 (i.color, 1);
            }
            ENDCG

        }
    }
}
```

[Accessing shader properties in Cg/HLSL](https://docs.unity3d.com/Manual/SL-ShaderPrograms.html)