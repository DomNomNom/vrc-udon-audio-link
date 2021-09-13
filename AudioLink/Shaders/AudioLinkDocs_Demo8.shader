﻿Shader "AudioLink/Examples/Demo8"
{
    Properties
    {
        _AudioLinkBand("AudioLink Band", Int) = 0
    }
    SubShader
    {
        // Allow users to make this effect transparent.
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #include "AudioLink.cginc"


            uniform uint _AudioLinkBand;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                //This is just the template vertex shader.
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float getBandAngle(uint column) {
                // Note: It's not performance optimal to do branching in shaders but it's quicker to develop this example.
                float v = AudioLinkData(uint2(0, _AudioLinkBand)).r;
                if (column == 0) return max(v-0.4, 0) * 2;
                if (column == 1) return v * 2 - 1;
                if (column == 2) return v > 0.4? 0 : 1;
                if (column == 3) return v > 0.4? -1 : 1;
                return 0;
            }

            float getCellAngle(uint2 grid_index)
            {
                uint2 offset = uint2(2 * grid_index.x + (grid_index.y - 1), _AudioLinkBand);
                return grid_index.y == 0 ?
                    getBandAngle(grid_index.x) :
                    (AudioLinkDecodeDataAsUInt(ALPASS_CHRONOTENSITY + offset) % 628319) / 100000.0;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 grid_dimensions = float2(4,3);
                float2 uv = i.uv * grid_dimensions;
                uint2 grid_index = floor(uv);
                float2 pos = (frac(uv)*2 - 1)  * 1.1;
                float angle = getCellAngle(grid_index);
                float2 chronotensityDir;
                sincos(angle, chronotensityDir.x, chronotensityDir.y);
                return float4(
                    lerp(
                        float3(grid_index / grid_dimensions * .7, 0),
                        float3(1,1,1),
                        smoothstep(.995, .996, dot(chronotensityDir, normalize(pos)))
                    ),
                    smoothstep(1, .99, length(pos))  // circular cutout
                );

            }
            ENDCG
        }
    }
}
