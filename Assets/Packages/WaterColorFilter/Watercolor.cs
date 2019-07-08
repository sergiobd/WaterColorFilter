using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


[Serializable]
[PostProcess(typeof(WatercolorEffect), PostProcessEvent.AfterStack, "Custom/Watercolor_v2", false)]
public sealed class Watercolor : PostProcessEffectSettings
{
    
    public TextureParameter wobbTex = new TextureParameter { };

    public FloatParameter wobbScale = new FloatParameter { value = 1f };

    public FloatParameter wobbPower = new FloatParameter { value = 0.005f };

    public FloatParameter edgeSize = new FloatParameter { value = 1f };

    public FloatParameter edgePower = new FloatParameter { value = 3f };

    public TextureParameter paperTex = new TextureParameter { };

    public FloatParameter paperScale = new FloatParameter { value = 1};

    public FloatParameter paperPower = new FloatParameter { value = 1 };

}

public sealed class WatercolorEffect : PostProcessEffectRenderer<Watercolor>
{

    public override void Render(PostProcessRenderContext context)
    {

        var sheet = context.propertySheets.Get(Shader.Find("Hidden/WaterColorFilter_v2"));
        
        sheet.properties.SetTexture("_WobbTex", settings.wobbTex);
        sheet.properties.SetFloat("_WobbScale", settings.wobbScale);
        sheet.properties.SetFloat("_WobbPower", settings.wobbPower);
        sheet.properties.SetFloat("_EdgeSize", settings.edgeSize);
        sheet.properties.SetFloat("_EdgePower", settings.edgeSize);
        sheet.properties.SetTexture("_PaperTex", settings.paperTex);

        sheet.properties.SetFloat("_PaperScale", settings.paperScale);
        sheet.properties.SetFloat("_PaperPower", settings.paperPower);

        sheet.properties.SetFloat("_DummyFloat", 0.1f);

        var rt0 = RenderTexture.GetTemporary(context.width, context.height, 0, RenderTextureFormat.ARGB32);
        var rt1 = RenderTexture.GetTemporary(context.width, context.height, 0, RenderTextureFormat.ARGB32);

        // Wobb
        context.command.BlitFullscreenTriangle(context.source, rt0, sheet, 0);

        // Edge
        
        context.command.BlitFullscreenTriangle(rt0, rt1, sheet, 1);

        //Paper - Please note that I only implemented a single paper. Original effect has multiple paper stacking.
        context.command.BlitFullscreenTriangle(rt1, context.destination, sheet, 2);

        RenderTexture.ReleaseTemporary(rt0);
        RenderTexture.ReleaseTemporary(rt1);


    }
}