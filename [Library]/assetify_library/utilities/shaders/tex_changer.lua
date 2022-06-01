----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shaders: tex_changer.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Texture Changer ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    file = file
}


-------------------
--[[ Variables ]]--
-------------------

local identifier = "Assetify_TextureChanger"
local depDatas, dependencies = "", {}
for i, j in imports.pairs(dependencies) do
    local depData = imports.file.read(j)
    if depData then
        depDatas = depDatas.."\n"..depData
    end
end


----------------
--[[ Shader ]]--
----------------

shaderRW[identifier] = function()
    return depDatas..[[
    /*-----------------
    -->> Variables <<--
    -------------------*/

    texture baseTexture;
    struct PSInput {
        float4 Position : POSITION0;
        float4 Diffuse : COLOR0;
        float2 TexCoord : TEXCOORD0;
    };
    struct Export {
        float4 World : COLOR0;
        float4 Render : COLOR1;
    };
    sampler baseSampler = sampler_state {
        Texture = baseTexture;
    };


    /*----------------
    -->> Handlers <<--
    ------------------*/

    Export PSHandler(PSInput PS) : COLOR0 {
        Export output;
        float4 sampledTexel = tex2D(baseSampler, PS.TexCoord);
        output.Render = vRenderingEnabled ? sampledTexel : 0;
        sampledTexel.rgb *= MTAGetWeatherValue();
        output.World = saturate(sampledTexel);
        return output;
    }


    /*------------------
    -->> Techniques <<--
    --------------------*/

    technique ]]..identifier..[[
    {
        pass P0
        {
            PixelShader = compile ps_2_0 PSHandler();
        }
    }

    technique fallback {
        pass P0 {}
    }
    ]]
end