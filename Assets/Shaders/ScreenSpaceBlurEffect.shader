//Code based on https://github.com/PacktPublishing/Unity-2018-Shaders-and-Effects-Cookbook-Third-Edition by Doran and Zucconi 

Shader "Custom/ScreenSpaceBlurEffect"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Steps ("Steps", Float) = 0
        
    }

    SubShader 
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize; //special value
            float _Steps;

            fixed4 frag(v2f_img i) : COLOR
            {
                
                float2 texel = float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y);
     
                float3 avg = 0.0;
        
                int steps = ((int)_Steps) * 2 + 1;
                if (steps < 0) 
                    avg = tex2D( _MainTex, i.uv).rgb;
                else 
                {
                    int x, y;
            
                    for ( x = -steps/2; x <=steps/2 ; x++) 
                        for (int y = -steps/2; y <= steps/2; y++) 
                            avg += tex2D( _MainTex, i.uv + texel * float2( x, y ) ).rgb;

                    avg /= steps * steps;
                }  
                
                return float4(avg, 1.0);
            }
        
        ENDCG
        }
    }
    FallBack off
}
