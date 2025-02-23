#define RAIN_SPEED 1.75 // Speed of rain droplets
#define DROP_SIZE  3.0  // Higher value lowers, the size of individual droplets

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rchar(vec2 outer, vec2 inner, float globalTime) {
    vec2 seed = floor(inner * 4.0) + outer.y;
    if (rand(vec2(outer.y, 23.0)) > 0.98) {
        seed += floor((globalTime + rand(vec2(outer.y, 49.0))) * 3.0);
    }
    
    return float(rand(seed) > 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Invert Y coordinate for bottom-left origin
    vec2 position = vec2(fragCoord.x, iResolution.y - fragCoord.y) / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy; // Keep original UV for terminal texture
    position.x /= iResolution.x / iResolution.y;
    float globalTime = iTime * RAIN_SPEED;
    
    float scaledown = DROP_SIZE;
    float rx = fragCoord.x / (40.0 * scaledown);
    float mx = 40.0*scaledown*fract(position.x * 30.0 * scaledown);
    vec4 result = vec4(0.0);
    
    // First rain pass
    if (mx <= 12.0 * scaledown) {
        float x = floor(rx);
        float r1x = floor(fragCoord.x / (15.0));
        // Update ry calculation to work with bottom-left origin
        float ry = position.y*600.0 + rand(vec2(x, x * 3.0)) * 100000.0 + globalTime* rand(vec2(r1x, 23.0)) * 120.0;
        float my = mod(ry, 15.0);
        
        if (my <= 12.0 * scaledown) {
            float y = floor(ry / 15.0);
            float b = rchar(vec2(rx, floor((ry) / 15.0)), vec2(mx, my) / 12.0, globalTime);
            float col = max(mod(-y, 24.0) - 4.0, 0.0) / 20.0;
            vec3 c = col < 0.8 ? vec3(0.0, col / 0.8, 0.0) : mix(vec3(0.0, 1.0, 0.0), vec3(1.0), (col - 0.8) / 0.2);
            result += vec4(c * b * 0.25, 1.0);
        }
    }
    
    // Second rain pass
    position.x += 0.05;
    rx = fragCoord.x / (40.0 * scaledown);
    mx = 40.0*scaledown*fract(position.x * 30.0 * scaledown);
    
    if (mx <= 12.0 * scaledown) {
        float x = floor(rx);
        float r1x = floor(fragCoord.x / (12.0));
        // Update ry calculation to work with bottom-left origin
        float ry = position.y*700.0 + rand(vec2(x, x * 3.0)) * 100000.0 + globalTime* rand(vec2(r1x, 23.0)) * 120.0;
        float my = mod(ry, 15.0);
        
        if (my <= 12.0 * scaledown) {
            float y = floor(ry / 15.0);
            float b = rchar(vec2(rx, floor((ry) / 15.0)), vec2(mx, my) / 12.0, globalTime);
            float col = max(mod(-y, 24.0) - 4.0, 0.0) / 20.0;
            vec3 c = col < 0.8 ? vec3(0.0, col / 0.8, 0.0) : mix(vec3(0.0, 1.0, 0.0), vec3(1.0), (col - 0.8) / 0.2);
            result += vec4(c * b * 0.25, 1.0);
        }
    }

    // Sample the terminal screen texture using original UV coordinates
    vec4 terminalColor = texture(iChannel0, uv);
    
    // Create a mask that is 1.0 where the terminal content is not black
    float mask = 1.2 - step(0.5, dot(terminalColor.rgb, vec3(1.0)));
    
    // Blend the matrix effect with the terminal color
    vec3 blendedColor = mix(terminalColor.rgb * 1.2, result.rgb, mask);
    
    fragColor = vec4(blendedColor, terminalColor.a);
}
