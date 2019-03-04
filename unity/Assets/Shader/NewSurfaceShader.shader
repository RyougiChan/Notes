Shader "Custom/NewSurfaceShader" {
	// See https://catlikecoding.com/unity/tutorials/rendering/part-4/ 
	// See https://docs.unity3d.com/Manual/SL-SurfaceShaders.html
	// See https://docs.unity3d.com/Manual/SL-SurfaceShaderLightingExamples.html
	// See http://www.alanzucconi.com/2015/06/17/surface-shaders-in-unity3d/
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ExtrudeAmount ("Extrude Amount", float) = 0
	}
	SubShader {
		// Tags 可以帮助您告诉渲染引擎如何以及何时渲染您正在编写的着色器。
		// Further study: https://docs.unity3d.com/Manual/SL-SubShaderTags.html
		// Opaque: 不透明，特别适用于生成深度纹理/贴图。
		Tags { "RenderType"="Opaque" }
		// 着色器细节级别或（LOD）有助于指定在某些硬件上使用哪个着色器。
		// LOD越高，着色器越“复杂”。该值与模型LOD无关。
		// Further study: https://docs.unity3d.com/Manual/SL-ShaderLOD.html
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// 定义一个名为surf的surface函数
		// “Standard”告诉Unity该着色器使用标准光照模型，“fullforwardshadows”指定此着色器应启用所有常规阴影类型。

		// 默认情况下，标准表面着色器不会暴露用于编辑顶点的函数。但我们仍然可以手动添加一个： vertex:vert。
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		// 指定编译哪个照明版本。值越高，越复杂，外观越好，但系统要求越多。
		// Further study: https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _ExtrudeAmount;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		// 这是着色器的核心。
		// Unity没有精确指定像素的颜色值，而是定义了SurfaceOutputStandard结构
		// 由于我们现在正在处理光照和阴影，我们不直接获取颜色，还需要根据SurfaceOutputStandard中保存的值进行计算
		/*
		以下是SurfaceOutputStandard的所有属性
		struct SurfaceOutput
		{
			fixed3 Albedo;  // diffuse color
			fixed3 Normal;  // tangent space normal, if written
			fixed3 Emission;
			half Specular;  // specular power in 0..1 range
			fixed Gloss;    // specular intensity
			fixed Alpha;    // alpha for transparencies
		};
		*/
		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		// “appdata_full”结构将由Unity自动填充我们正在渲染的模型的属性。无需手动创建
		// See https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html
		// 如果您注意到更新顶点但阴影也未更新时，请确保添加“addshadow”编译指示，如下所示：
		// #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		void vert(inout appdata_full v){
			v.vertex.xyz += v.normal.xyz * _ExtrudeAmount * sin(_Time.y);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
