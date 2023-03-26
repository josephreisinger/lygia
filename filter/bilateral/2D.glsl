#include "../../color/space/rgb2luma.glsl"
#include "../../sample.glsl"

/*
original_author: Patricio Gonzalez Vivo
description: | 
    This is a two dimensioanl Bilateral filter (for a single pass) It's a non-linear, edge-preserving, and noise-reducing
    smoothing filter for images. It replaces the intensity of each pixel with a weighted average of
    intensity values from nearby pixels. This filter is very effective at noise removal while
    preserving edges. It is very similar to the Gaussian blur, but it also takes into account the
    intensity differences between a pixel and its neighbors. This is what makes it particularly
    effective at noise removal while preserving edges.

    Other examples https://www.shadertoy.com/view/4dfGDH , https://www.shadertoy.com/view/XtVGWG

use: bilateral2D(<sampler2D> texture, <vec2> st, <vec2> offset, <int> kernelSize)
options:
    - BILATERAL2D_TYPE: default is vec3
    - BILATERAL2D_SAMPLER_FNC(TEX, UV): default texture2D(TEX, UV)
    - BILATERAL2D_LUMA(RGB): default rgb2luma
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
examples:
    - /shaders/filter_bilateral2D.frag
*/

#ifndef BILATERAL2D_TYPE
#ifdef BILATERAL_TYPE
#define BILATERAL2D_TYPE BILATERAL_TYPE
#else
#define BILATERAL2D_TYPE vec4
#endif
#endif

#ifndef BILATERAL2D_SAMPLER_FNC
#ifdef BILATERAL_SAMPLER_FNC
#define BILATERAL2D_SAMPLER_FNC(TEX, UV) BILATERAL_SAMPLER_FNC(TEX, UV)
#else
#define BILATERAL2D_SAMPLER_FNC(TEX, UV) SAMPLER_FNC(TEX, UV)
#endif
#endif

#ifndef BILATERAL2D_LUMA
#define BILATERAL2D_LUMA(RGB) rgb2luma(RGB.rgb)
#endif

#ifndef FNC_BILATERAL2D
#define FNC_BILATERAL2D
BILATERAL2D_TYPE bilateral2D(in sampler2D tex, in vec2 st, in vec2 offset, const int kernelSize) {
    BILATERAL2D_TYPE accumColor = BILATERAL2D_TYPE(0.);

    #ifndef BILATERAL2D_KERNELSIZE
    #if defined(PLATFORM_WEBGL)
    #define BILATERAL2D_KERNELSIZE 20
    float kernelSizef = float(kernelSize);
    #else
    #define BILATERAL2D_KERNELSIZE kernelSize
    float kernelSizef = float(BILATERAL2D_KERNELSIZE);
    #endif
    #else 
    float kernelSizef = float(BILATERAL2D_KERNELSIZE);
    #endif
    
    float accumWeight = 0.;
    const float k = .15915494; // 1. / (2.*PI)
    const float k2 = k * k;
    
    float kernelSize2 = kernelSizef * kernelSizef;
    BILATERAL2D_TYPE tex0 = BILATERAL2D_SAMPLER_FNC(tex, st);
    float lum0 = BILATERAL2D_LUMA(tex0);

    for (int j = 0; j < BILATERAL2D_KERNELSIZE; j++) {
        #if defined(PLATFORM_WEBGL)
        if (j >= kernelSize)
            break;
        #endif
        float dy = -.5 * (kernelSizef - 1.0) + float(j);
        for (int i = 0; i < BILATERAL2D_KERNELSIZE; i++) {
            #if defined(PLATFORM_WEBGL)
            if (i >= kernelSize)
                break;
            #endif
            float dx = -.5 * (kernelSizef - 1.0) + float(i);
            BILATERAL2D_TYPE t = BILATERAL2D_SAMPLER_FNC(tex, st + vec2(dx, dy) * offset);
            float lum = BILATERAL2D_LUMA(t);
            float dl = 255. * (lum - lum0);
            float weight = (k2 / kernelSize2) * exp(-(dx * dx + dy * dy + dl * dl) / (2. * kernelSize2));
            accumColor += weight * t;
            accumWeight += weight;
        }
    }
    return accumColor / accumWeight;
}
#endif