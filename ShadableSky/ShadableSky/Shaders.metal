
#include <metal_stdlib>
using namespace metal;

#include <SceneKit/scn_metal>

struct VertexIn {
    float3 position  [[attribute(SCNVertexSemanticPosition)]];
    float2 texCoords [[attribute(SCNVertexSemanticTexcoord0)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
};

struct NodeConstants {
    float4x4 modelTransform;
    float4x4 modelViewProjectionTransform;
};

vertex VertexOut sky_vertex(VertexIn in [[stage_in]],
                            constant NodeConstants &scn_node [[buffer(1)]])
{
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1);
    out.texCoords = in.texCoords;
    return out;
}

fragment half4 sky_fragment(VertexOut in [[stage_in]],
                            texture2d<float, access::sample> skyTexture [[texture(0)]],
                            constant SCNSceneBuffer &scn_frame [[buffer(0)]],
                            constant float &timeOfDay [[buffer(2)]])
{
    constexpr sampler skySampler(coord::normalized, address::repeat, filter::linear);
    float2 skyCoords(timeOfDay, in.texCoords.y);
    float4 skyColor = skyTexture.sample(skySampler, skyCoords);
    return half4(half3(skyColor.rgb), 1);
}
