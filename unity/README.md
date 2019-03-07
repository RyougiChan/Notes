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
    }
}

```