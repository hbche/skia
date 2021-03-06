#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
struct Inputs {
    float4 srcdst;
};
struct Outputs {
    float4 sk_FragColor [[color(0)]];
};

float4 blend_dst(float4 src, float4 dst) {
    return dst;
}
fragment Outputs fragmentMain(Inputs _in [[stage_in]], bool _frontFacing [[front_facing]], float4 _fragCoord [[position]]) {
    Outputs _outputStruct;
    thread Outputs* _out = &_outputStruct;
    float4 _0_blend_dst;
    {
        _0_blend_dst = _in.dst;
    }

    _out->sk_FragColor = _0_blend_dst;

    return *_out;
}
