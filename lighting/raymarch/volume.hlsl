/*
contributors:  Inigo Quiles
description: Default raymarching renderer
use: <vec4> raymarchDefaultRender( in <float3> rayOriging, in <float3> rayDirection, in <float3> cameraForward,
    out <float3> eyeDepth, out <float3> worldPosition, out <float3> worldNormal ) 
options:
    - RAYMARCH_MATERIAL_FNC(RGB) float3(RGB)
    - RAYMARCH_BACKGROUND float3(0.0)
    - LIGHT_COLOR     float3(0.5)
    - LIGHT_POSITION  float3(0.0, 10.0, -50.0)
*/

#ifndef LIGHT_COLOR
#if defined(GLSLVIEWER)
#define LIGHT_COLOR u_lightColor
#else
#define LIGHT_COLOR float3(0.5, 0.5, 0.5)
#endif
#endif

#ifndef RAYMARCH_BACKGROUND
#define RAYMARCH_BACKGROUND float3(0.0, 0.0, 0.0)
#endif

#ifndef RAYMARCH_SAMPLES
#define RAYMARCH_SAMPLES 64
#endif

#ifndef RAYMARCH_MIN_DIST
#define RAYMARCH_MIN_DIST 1.0
#endif

#ifndef RAYMARCH_MAX_DIST
#define RAYMARCH_MAX_DIST 10.0
#endif

#ifndef RAYMARCH_VOLUME_COLOR_FNC
#define RAYMARCH_VOLUME_COLOR_FNC float3
#endif

#ifndef RAYMARCH_MAP_FNC
#define RAYMARCH_MAP_FNC(POS) raymarchMap(POS)
#endif

#ifndef FNC_RAYMARCHVOLUMERENDER
#define FNC_RAYMARCHVOLUMERENDER

vec4 raymarchVolume( in vec3 rayOrigin, in vec3 rayDirection, vec3 cameraForward,
                     out float eyeDepth, out vec3 worldPos, out vec3 worldNormal) {

    const float tmin        = RAYMARCH_MIN_DIST;
    const float tmax        = RAYMARCH_MAX_DIST;
    const float fSamples    = float(RAYMARCH_SAMPLES);
    const float tstep       = tmax/fSamples;
    const float absorption  = 100.;

    #ifdef LIGHT_POSITION
    const int   nbSampleLight   = 6;
    const float fSampleLight    = float(nbSampleLight);
    const float tstepl          = tmax/fSampleLight;
    float3 sun_direction          = normalize( LIGHT_POSITION );
    #endif

    float T = 1.;
    float t = tmin;
    float3 col = float3(0.0, 0.0, 0.0);
    float3 pos = rayOrigin;
    for(int i = 0; i < RAYMARCH_SAMPLES; i++) {
        float4 res    = RAYMARCH_MAP_FNC(pos);
        float density = (0.1 - res.a);
        if (density > 0.0) {
            float tmp = density / fSamples;
            T *= 1.0 - tmp * absorption;
            if( T <= 0.001)
                break;

            col += RAYMARCH_VOLUME_COLOR_FNC(res.rgb) * fSamples * tmp * T;
                
            //Light scattering
            #ifdef LIGHT_POSITION
            float Tl = 1.0;
            for (int j = 0; j < nbSampleLight; j++) {
                float densityLight = RAYMARCH_MAP_FNC( pos + sun_direction * float(j) * tstepl ).a;
                if (densityLight>0.)
                    Tl *= 1. - densityLight * absorption/fSamples;
                if (Tl <= 0.01)
                    break;
            }
            col += LIGHT_COLOR * 80. * tmp * T * Tl;
            #endif
        }
        pos += rayDirection * tstep;
    }

    worldPos = rayOrigin + t * rayDirection;
    worldNormal = raymarchNormal( worldPos );
    eyeDepth = t * dot(rayDirection, cameraForward);

    return float4(col, t);
}

#endif