#include "../sample.glsl"
#include "../color/space/rgb2heat.glsl"

/*
contributors: Patricio Gonzalez Vivo
description: sample a value encoded on a heatmap
use: sampleFlow(<SAMPLER_TYPE> tex, <vec2> st)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
*/

#ifndef SAMPLEHEATMAP_SAMPLE_FNC
#define SAMPLEHEATMAP_SAMPLE_FNC(TEX, UV) SAMPLER_FNC(TEX, UV).rgb
#endif

#ifndef FNC_SAMPLEHEATMAP
#define FNC_SAMPLEHEATMAP
float sampleHeatmap(sampler2D tex, vec2 st) { return rgb2heat( SAMPLEHEATMAP_SAMPLE_FNC(tex, st) ); }
float sampleHeatmap(sampler2D tex, vec2 st, float _min, float _max) { return  _min + sampleHeatmap(tex, st) * (_max - _min); }
#endif