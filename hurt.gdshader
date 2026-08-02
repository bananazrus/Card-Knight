shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.0, 1.0) = 0.45;   // Higher = pushed further to edges
uniform float softness : hint_range(0.0, 1.0) = 0.15; // Lower = sharper edge fade

void fragment() {
    // Center UV coordinates
    vec2 uv = UV - vec2(0.5);
    
    // Calculate distance from center
    float dist = length(uv);
    
    // Vignette starts at 'radius' and reaches full intensity at 'radius + softness'
    float vignette = smoothstep(radius, radius + softness, dist);
    
    COLOR = vec4(vignette_color.rgb, vignette * intensity * vignette_color.a);
}