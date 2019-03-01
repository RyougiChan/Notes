Shader "Unlit/Tutorial_Shader"
{
	// 在属性块中，我们可以传递一些自定义数据。
	// 我们在这里声明的数据将被显示在Unity Editor面板中，在Editor中更改也会驱动脚本更改。
	Properties {
	
	}

	// 每一个Shader有一个或者多个SubShader
	// 如果你的应用将被部署到多种平台（移动、PC、主机）,添加多个SubShader是非常有用的
	SubShader {
		// 每个SubShader至少有一个Pass语句块，它实际上是对象渲染的位置。
		// 一些特效要求有多个Pass语句块
		Pass {
			// 我们实际写的所有Shader代码都在CGPROGRAM和ENDCG中，对于Unity来说，shaderlab是HLSL和CG的变体。
			CGPROGRAM
				// 我们需要告诉Unity，顶点函数和片元函数是什么
				#pragma vertex vertexFunction
				#pragma fragment fragmentFunction
				// 在开始着色之前，我们需要设置一些数据结构和两个函数
				// 这样，我们就可以使用Unity给定的数据，并把数据返回到Unity中
				#include "UnityCG.cginc"
				
				// 我们可以传递一些自定义的数据格式如 `[type] [name] :[semantic]`
				// 例如要求Unity获取模型对象的顶点坐标 `flot4 vertex:POSITION;`
				struct a2v{
					// 从Unity中获取顶点坐标和UV纹理坐标
					float4 vertex:POSITION;
					float2 uv:TEXCOORD0;
				};

				// 最后配置顶点函数，创建一个结构体，并将其命名v2f(代表从vertex to fragment，顶点数据传递到片元)
				struct v2f {
					// 我们可以在v2f结构体中定义一些数据
					// 我们可能想要把这些数据从顶点函数传递到片元函数
					// SV: system value
					float4 position:SV_POSITION;
					float2 uv:TEXCOORD0;
				};

				// 当传递一个参数到vertexFunction中时，Unity将解析这个函数的结构，并基于正在绘制的对象模型传递值。
				// 将vertex中包含的数据传递到片元函数，同时确保vertexFunction 返回 v2f的数据类型
				v2f vertexFunction(a2v v){
					v2f o;
					/* 获取顶点的正确位置, UNnityObjectToClipPos将世界空间的模型坐标转换到裁剪空间 */
					o.position = UnityObjectToClipPos(v.vertex);
					return o;
				}

				// fixed4: 输出的片元函数将是一个有（R,G,B,A)代表的颜色值
				// 我们将为片元函数添加一个SV_TARGET的输出语义,这个过程告诉Unity我们将输出一个color去渲染
				fixed4 fragmentFunction(v2f i):SV_TARGET{
					//
					return fixed4(0,1,0,1);
				}
			ENDCG
		}
	}
}
