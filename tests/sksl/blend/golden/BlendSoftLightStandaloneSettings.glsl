
out vec4 sk_FragColor;
in vec4 src, dst;
float _guarded_divide(float n, float d) {
    return n / d;
}
float _soft_light_component(vec2 s, vec2 d) {
    if (2.0 * s.x <= s.y) {
        float _1_guarded_divide;
        float _2_n = (d.x * d.x) * (s.y - 2.0 * s.x);
        float _3_d = d.y;
        {
            _1_guarded_divide = _2_n / _3_d;
        }
        return (_1_guarded_divide + (1.0 - d.y) * s.x) + d.x * ((-s.y + 2.0 * s.x) + 1.0);

    } else if (4.0 * d.x <= d.y) {
        float DSqd = d.x * d.x;
        float DCub = DSqd * d.x;
        float DaSqd = d.y * d.y;
        float DaCub = DaSqd * d.y;
        float _4_guarded_divide;
        float _5_n = ((DaSqd * (s.x - d.x * ((3.0 * s.y - 6.0 * s.x) - 1.0)) + ((12.0 * d.y) * DSqd) * (s.y - 2.0 * s.x)) - (16.0 * DCub) * (s.y - 2.0 * s.x)) - DaCub * s.x;
        {
            _4_guarded_divide = _5_n / DaSqd;
        }
        return _4_guarded_divide;

    } else {
        return ((d.x * ((s.y - 2.0 * s.x) + 1.0) + s.x) - sqrt(d.y * d.x) * (s.y - 2.0 * s.x)) - d.y * s.x;
    }
}
vec4 blend_soft_light(vec4 src, vec4 dst) {
    return dst.w == 0.0 ? src : vec4(_soft_light_component(src.xw, dst.xw), _soft_light_component(src.yw, dst.yw), _soft_light_component(src.zw, dst.zw), src.w + (1.0 - src.w) * dst.w);
}
void main() {
    vec4 _0_blend_soft_light;
    {
        _0_blend_soft_light = dst.w == 0.0 ? src : vec4(_soft_light_component(src.xw, dst.xw), _soft_light_component(src.yw, dst.yw), _soft_light_component(src.zw, dst.zw), src.w + (1.0 - src.w) * dst.w);
    }

    sk_FragColor = _0_blend_soft_light;

}
