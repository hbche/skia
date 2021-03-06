#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
struct Inputs {
    float4 srcdst;
};
struct Outputs {
    float4 sk_FragColor [[color(0)]];
};

float4 blend_src_atop(float4 src, float4 dst) {
    return dst.w * src + (1.0 - src.w) * dst;
}
fragment Outputs fragmentMain(Inputs _in [[stage_in]], bool _frontFacing [[front_facing]], float4 _fragCoord [[position]]) {
    Outputs _outputStruct;
    thread Outputs* _out = &_outputStruct;
    float4 _0_blend_src_atop;
    {
        _0_blend_src_atop = _in.dst.w * _in.src + (1.0 - _in.src.w) * _in.dst;
    }

    _out->sk_FragColor = _0_blend_src_atop;

    return *_out;
}
