// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Outline"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ColorOutline ("Outline Color", Color) = (0, 0, 0, 1)
        _EdgeWidth ("Outline Width", Range (0.001,1)) = 0.1//Range(0.0, 1.0)

        _EmmisiveColor("Emmisive Color", Color) = (1, 1, 1, 1)
        _Emissiveness("Emmissiveness", Range(0,10)) = 0
        _Shininess ("Shininess", Float) = 10 //Shininess
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

		//	Outline Pass
        Pass
        {
			Tags { "LightMode" = "Always" }

        	Cull Front
			ZWrite Off
			ZTest Always

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
    
            uniform float4 _EmmisiveColor;
            uniform float _Emissiveness;   

            float4 _ColorOutline;
            float _EdgeWidth;

            struct appdata
            {
                float4 vertex : POSITION;
            	float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex + float4(v.normal, 1.0) * _EdgeWidth);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
              
                fixed4 col = _EmmisiveColor * _Emissiveness + _ColorOutline;

                return col;
            }
            ENDCG
        }
        //	Phonge Shader 
        /*Pass
        {
            //Tags { "LightMode" = "ForwardAdd" } //Important! In Unity, point lights are calculated in the the ForwardAdd pass
            //Blend One One //Turn on additive blending if you have more than one point light

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            uniform float4 _LightColor0; //From UnityCG
            uniform float4 _Color; 
            uniform float4 _SpecColor;
            uniform float _Shininess;
            sampler _MainTex;  

            struct appdata
            {
                float4 vertex : POSITION;
            	float3 normal : NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;       
                float3 vertexInWorldCoords : TEXCOORD1;
                float2 uv: TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex); //Vertex position in WORLD coords
                o.normal =  mul(unity_ObjectToWorld, v.normal); //Normal 
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex); 
                
             	
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
              
                float3 P = i.vertexInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 H = normalize(L + V);
                
                float3 Kd = _Color.rgb; //Color of object
                float3 Ka = UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                //float3 Ka = float3(0,0,0); //UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                float3 Ks = _SpecColor.rgb; //Color of specular highlighting
                float3 Kl = _LightColor0.rgb; //Color of light
                
                
                //AMBIENT LIGHT 
                float3 ambient = Ka;
                
               
                //DIFFUSE LIGHT
                float diffuseVal = max(dot(N, L), 0);
                float3 diffuse = Kd * Kl * diffuseVal;
                
                
                //SPECULAR LIGHT
                float specularVal = pow(max(dot(N,H), 0), _Shininess);
                
                if (diffuseVal <= 0) {
                    specularVal = 0;
                }
                
                float3 specular = Ks * Kl * specularVal;
                
                float4 texColor = tex2D(_MainTex, i.uv);
                //FINAL COLOR OF FRAGMENT
              	
              	//return float4(0,0,0,0);
                return float4(ambient+ diffuse + specular, 1.0)*texColor;
            }
            ENDCG
        }// */
        //	My Phonge from assignment one
        Pass {	
	        Tags { "LightMode" = "ForwardBase" } 
	            // pass for ambient light and first light source
	 
	        CGPROGRAM
	 
	        #pragma vertex vert  
	        #pragma fragment frag 
	 
	        #include "UnityCG.cginc"
	        uniform float4 _LightColor0; 
	            // color of light source (from "Lighting.cginc")
	 
	        // User-specified properties
	        uniform float4 _Color; 
	        uniform float4 _SpecColor; 
	        uniform float _Shininess;
	        sampler2D _MainTex;
	        sampler2D _SecondTex;
	 
	        struct vertexInput {
	            float4 vertex : POSITION;
	            float3 normal : NORMAL;
	         	float2 uv : TEXCOORD0;
	        };
	        struct vertexOutput {
	            float4 pos : SV_POSITION;
	            float4 posWorld : TEXCOORD1;
	            float3 normalDir : NORMAL;
	            float2 uv : TEXCOORD0;
	        };
	 
	        vertexOutput vert(vertexInput input) 
	        {
	            vertexOutput output;
	 
	            float4x4 modelMatrix = unity_ObjectToWorld;
	            float4x4 modelMatrixInverse = unity_WorldToObject; 
	 
	            output.posWorld = mul(modelMatrix, input.vertex);
	            output.normalDir = normalize(
	               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
	            output.pos = UnityObjectToClipPos(input.vertex);
	            output.uv = input.uv;
	            return output;
	        }
	 
	        float4 frag(vertexOutput input) : COLOR
	        {
	            float3 normalDirection = normalize(input.normalDir);
	 
	            float3 viewDirection = normalize(
	               _WorldSpaceCameraPos - input.posWorld.xyz);
	            float3 lightDirection;
	            float attenuation;
	 
	            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
	            {
	               attenuation = 1.0; // no attenuation
	               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
	            } 
	            else // point or spot light
	            {
	               float3 vertexToLightSource = 
	                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
	               float distance = length(vertexToLightSource);
	               attenuation = 1.0 / distance; // linear attenuation 
	               lightDirection = normalize(vertexToLightSource);
	            }
	 
	            float3 ambientLighting = 
	               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
	 
	            float3 diffuseReflection = 
	               attenuation * _LightColor0.rgb * _Color.rgb
	               * max(0.0, dot(normalDirection, lightDirection));
	 
	            float3 specularReflection;
	            if (dot(normalDirection, lightDirection) < 0.0) 
	               // light source on the wrong side?
	            {
	               specularReflection = float3(0.0, 0.0, 0.0); 
	                  // no specular reflection
	            }
	            else // light source on the right side
	            {
	               specularReflection = attenuation * _LightColor0.rgb 
	                  * _SpecColor.rgb * pow(max(0.0, dot(
	                  reflect(-lightDirection, normalDirection), 
	                  viewDirection)), _Shininess);
	            }

	            return float4((ambientLighting + diffuseReflection) * tex2D(_MainTex, input.uv) + specularReflection, 1.0);
	            
	        }
	 
	         ENDCG
    	}
 
      	Pass {	
         	Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         	Blend One One // additive blending 
	 
	        CGPROGRAM
	 
	        #pragma vertex vert  
	        #pragma fragment frag 
	 
	        #include "UnityCG.cginc"
	        uniform float4 _LightColor0; 
	            // color of light source (from "Lighting.cginc")
	 
	        // User-specified properties
	        uniform float4 _Color;
	        uniform float4 _SpecColor;
	        uniform float _Shininess;
	        sampler2D _MainTex;
	        sampler2D _SecondTex;

	        struct vertexInput {
	              float4 vertex : POSITION;
	              float3 normal : NORMAL;
	              float2 uv : TEXCOORD0;
	        };
	        struct vertexOutput {
	            float4 pos : SV_POSITION;
	            float4 posWorld : TEXCOORD1;
	            float3 normalDir : NORMAL;
	            float2 uv : TEXCOORD0;
        	};

	        vertexOutput vert(vertexInput input)
	        {
	              vertexOutput output;

	              float4x4 modelMatrix = unity_ObjectToWorld;
	              float4x4 modelMatrixInverse = unity_WorldToObject;

	              output.posWorld = mul(modelMatrix, input.vertex);
	              output.normalDir = normalize(
	                  mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
	              output.pos = UnityObjectToClipPos(input.vertex);
	              output.uv = input.uv;
	              return output;
	        }
	 
	        float4 frag(vertexOutput input) : COLOR
	        {
	            float3 normalDirection = normalize(input.normalDir);
	 
	            float3 viewDirection = normalize(
	               _WorldSpaceCameraPos - input.posWorld.xyz);
	            float3 lightDirection;
	            float attenuation;
	 
	            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
	            {
	               attenuation = 1.0; // no attenuation
	               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
	            } 
	            else // point or spot light
	            {
	               float3 vertexToLightSource = 
	                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
	               float distance = length(vertexToLightSource);
	               attenuation = 1.0 / distance; // linear attenuation 
	               lightDirection = normalize(vertexToLightSource);
	            }
	 
	            float3 diffuseReflection = 
	               attenuation * _LightColor0.rgb * _Color.rgb
	               * max(0.0, dot(normalDirection, lightDirection));
	 
	            float3 specularReflection;
	            if (dot(normalDirection, lightDirection) < 0.0) 
	               // light source on the wrong side?
	            {
	               specularReflection = float3(0.0, 0.0, 0.0); 
	                  // no specular reflection
	            }
	            else // light source on the right side
	            {
	               specularReflection = attenuation * _LightColor0.rgb 
	                  * _SpecColor.rgb * pow(max(0.0, dot(
	                  reflect(-lightDirection, normalDirection), 
	                  viewDirection)), _Shininess);
	            }

	            return float4(diffuseReflection * tex2D(_MainTex, input.uv) + specularReflection, 1.0);
	            
	            // no ambient lighting in this pass
	        }
 
         ENDCG
        }
   
    }
}
