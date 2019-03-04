Shader "Unlit/Tutorial_Shader_Template"
{
	// 资料 https://github.com/Centribo/Unity-Shader-Basics-Tutorial
	// 在属性块中，我们可以传递一些自定义数据。
	// 我们在这里声明的数据将被显示在Unity Editor面板中，在Editor中更改也会驱动脚本更改。
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
					// 法线
					float3 normal : NORMAL;
				};

				// 最后配置顶点函数，创建一个结构体，并将其命名v2f(代表从vertex to fragment，顶点数据传递到片元)
				struct v2f {
					// 我们可以在v2f结构体中定义一些数据
					// 我们可能想要把这些数据从顶点函数传递到片元函数
					// SV: system value
					float4 position:SV_POSITION;
					float2 uv:TEXCOORD0;
				};

				float4 _Colour;
				sampler2D _MainTexture;
				sampler2D _DissolveTexture;
				float _DissolveCutoff;
				float _ExtrudeAmount;

				// 当传递一个参数到vertexFunction中时，Unity将解析这个函数的结构，并基于正在绘制的对象模型传递值。
				// 将vertex中包含的数据传递到片元函数，同时确保vertexFunction 返回 v2f的数据类型
				v2f vertexFunction(a2v v){
					v2f o;
					// 在我们将顶点转换出局部模型空间之前，
					// 我们将通过将它们的法线方向加到_ExtrudeAmount来向外偏移一定量
					// _Time是UnityCG.cginc中包含的变量，表示时间，y值表示秒
					v.vertex.xyz += v.normal.xyz * _ExtrudeAmount * sin(_Time.y);
					o.position = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				// fixed4: 输出的片元函数将是一个有（R,G,B,A)代表的颜色值
				// 我们将为片元函数添加一个SV_TARGET的输出语义,这个过程告诉Unity我们将输出一个color去渲染
				fixed4 fragmentFunction(v2f i):SV_TARGET{
					float4 textureColour = tex2D(_MainTexture, i.uv);
					// 对溶解纹理进行采样
					float4 dissolveColour = tex2D(_DissolveTexture, i.uv);
					// clip函数通过检查给定的值是否小于0来工作。
					// 如果是，则我们丢弃像素并且不绘制任何内容。
					// 如果不是，我们保留像素并继续。
					clip(dissolveColour.rgb - _DissolveCutoff);
					return textureColour * _Colour;;
					//return _Colour;
				}
			ENDCG
		}
	}
}
