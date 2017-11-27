float DF_Sphere(float3 Center, float Radius, float3 Position)
{
    return distance(Center, Position) - Radius;
}


    float3 Center0 = float3(0.0, 0.0, 0.0);
    float Radius0 = 20.0;
    float d0 = CustomExpression0(Parameters, Center0, Radius0, Position);

    float3 Center1 = float3(0.0, 0.0, 0.0);
    float Radius1 = 20.0;
    float AnimRadius = 40.0;
    float Hz = 0.2;
    float Phase = ResolvedView.GameTime *  2.0 * PI * Hz;
    Center1.xy = float2(cos(Phase), sin(Phase)) * AnimRadius;
    float d1 = CustomExpression0(Parameters, Center1, Radius1, Position);

    return min(d0, d1);

float DF_Scene(float3 Position)
{
    float3 Center = float3(0.0, 0.0, 0.0);
    float Radius = 1.0;

    float d0 = DF_Sphere(Center, Radius, Position);
    // TODO: more geometry and blending

    return d0;
}

float Trace(float3 RayOrigin, float3 RayDirection)
{
    float MaxDistance = 10.0;
    int MaxStep = 64;
    float Precision = 0.001;

    float t = 0.0;

    for (int i = 0; i < MaxStep; i++)
    {
        float d = DF_Scene(RayOrigin + RayDirection * t);
        t += d;
        if (d <= Precision) return t;
        if (t > MaxDistance) return -1.0;
    }
    return -1.0;
}


(2*t*t*t - 3*t*t + 1) * p0 + (t*t*t - 2*t*t + t) * m0 + (-2*t*t*t + 3*t*t) * p1 + (t*t*t - t*t) * m1

smoother(diff, k, l)

diff = clamp(diff, 0.0, k);
float t = diff / k;
float p0 = k - l;
float m0 = 0;
float p1 = 0;
float m1 = -1;
return (2*t*t*t - 3*t*t + 1) * p0 + (t*t*t - 2*t*t + t) * m0 + (-2*t*t*t + 3*t*t) * p1 + (t*t*t - t*t) * m1;


//////

smoothmin(x, y, k, l)

float diff = distance(x, y);

diff = clamp(diff, 0.0, k);
float t = diff / k;
float p0 = k - l;
float m0 = 0;
float p1 = 0;
float m1 = -1;
float bias = (2*t*t*t - 3*t*t + 1) * p0 + (t*t*t - 2*t*t + t) * m0 + (-2*t*t*t + 3*t*t) * p1 + (t*t*t - t*t) * m1;

return min(x, y) - bias;


//////

smoothmin(x, y, k)

float h = clamp(y - x, -1.0, 1.0);
h = h * 0.5 + 1.0;
return lerp(x, y, h);


/////

DF_SceneNormal

float e = 0.01;
float e_x0 = float3(e, 0.0, 0.0);
float e_x1 = -e_x0;
float e_y0 = float3(0.0, e, 0.0);
float e_y1 = -e_y0;
float e_z0 = float3(0.0, 0.0, e);
float e_z1 = -e_z0;

float d_x = CustomExpression2(Parameters, Position + e_x1) - CustomExpression2(Parameters, Position + e_x0);
float d_y = CustomExpression2(Parameters, Position + e_y1) - CustomExpression2(Parameters, Position + e_y0);
float d_z = CustomExpression2(Parameters, Position + e_z1) - CustomExpression2(Parameters, Position + e_z0);

return normalize(float3(d_x, d_y, d_z));


DF_TraceDensity(RayOrigin, RayDirection)

int MaxStep = 64;
float StepDistance = 1.0;

float Acc = 0.0;
float StepAcc = 1.0;

for (int i = 0; i < MaxStep; i++)
{
    float3 Position = RayOrigin + RayDirection * StepDistance * i;
    float d = CustomExpression2(Parameters, Position);
    if (d <= 0) {
      Acc += StepAcc;
    }
}

return Acc;

// return float2(<scene_depth>, <scene_density>)
DF_Main()

float MaxDistance = 1000.0;
int MaxStep = 64;
float Precision = 0.001;

float t = 0.0;

for (int i = 0; i < MaxStep; i++)
{
    float d = CustomExpression2(Parameters, RayOrigin + RayDirection * t);
    t += d;
    if (d <= Precision)
    {
      float density = CustomExpression4(Parameters, RayOrigin + RayDirection * t, RayDirection);
      return float2(t, density);
    }
    if (t > MaxDistance) {
      return float2(-1.0, 0.0);
    }
}

return float2(-1.0, 0.0);



//// UVToVolumePosition(float2 uv, float2 size) ////

float2 tmp0 = uv * size;
float2 xy = frac(tmp0);
float2 tmp1 = floor(tmp0);
float z = (tmp1.x + tmp1.y * size.x) / (size.x * size.y);
return float3(xy, z);


//// CloudRayMarch(ray_origin, ray_direction, texture_object, flipbook_size, max_step, step_length) ////

float3 color = float3(0, 0, 0);
float density = 0;

for (int i = 0; i < max_step; i++) {
    float3 p = ray_origin + i * ray_direction * step_length;

    if (p.x >= 0 && p.y >= 0 && p.z >= 0 &&
        p.x <= 1 && p.y <= 1 && p.z <= 1) {
        float volume_sample = PseudoVolumeTexture(texture_object, texture_objectSampler, p,
                flipbook_size, flipbook_size.x * flipbook_size.y).r;
        density += volume_sample;
    }
}

return float4(color, density);

//// CloudRayMarch2(ray_origin, ray_direction, texture_object, flipbook_size, max_step, step_length
////         density_scale, light_direction, light_color, max_step2, step_length2, density_scale2, powder_scale)
// TODO:
// - Henyen-Greenstein
// - jitter
// - render backface

float3 cloud_color = float3(1, 1, 1);
float3 acc_color = float3(0, 0, 0);
float acc_density = 0;

// trace view ray
for (int i = 0; i < max_step; i++) {
    float3 p = ray_origin + i * ray_direction * step_length;

    if (p.x >= 0 && p.y >= 0 && p.z >= 0 && p.x <= 1 && p.y <= 1 && p.z <= 1) {
        float sample0 = PseudoVolumeTexture(texture_object, texture_objectSampler, p,
                flipbook_size, flipbook_size.x * flipbook_size.y).r;

        // trace point p to sun
        float sample1 = 0;
        for (int j = 0; j < max_step2; j++) {
            float3 q = p + j * light_direction * step_length2;
            if (q.x >= 0 && q.y >= 0 && q.z >= 0 && q.x <= 1 && q.y <= 1 && q.z <= 1) {
                sample1 += PseudoVolumeTexture(texture_object, texture_objectSampler, q,
                        flipbook_size, flipbook_size.x * flipbook_size.y).r;
            }
        }

        // lighting of point p
        float3 p_color = cloud_color * light_color *
                (1 - exp(- sample0 * density_scale)) * // opacity of point p
                exp(- sample1 * density_scale2) *      // transmittance from sun to p
                exp(- acc_density);                    // transmittance from p to view

        // beer powder factor
        p_color *= (1 - exp(- acc_density * powder_scale));

        // accumulate
        acc_color += p_color;
        acc_density += sample0 * density_scale;
    }
}

return float4(acc_color, 1 - exp(- acc_density));


//// VolumePositionToUV(float3 position, float2 size) ////

float tmp0 = position.z * size.x * size.y;
float tmp1 = floor(tmp0);
float alpha = frac(tmp0);
float2 uv_xy = position.xy / size;
float2 uv_z1 = float2(fmod(tmp1, size.x), floor(tmp1 / size.x));
float2 uv_z2 = float2(fmod(tmp1 + 1, size.x), floor((tmp1 + 1)/ size.x));

// return (uv1, uv2, alpha)


/// BoxMask(position, d0, d1)

position = abs(position - 0.5) - d0;
return saturate(1 - length(max(position, 0.0)) / d1);
