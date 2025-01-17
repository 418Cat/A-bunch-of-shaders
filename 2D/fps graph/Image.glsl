opt_color getFrameGraphColor(vec2 uv)
{
    /*
        Scale UV so the coordinates between [0, 1] are in the graph
    */
    vec2 scaled_uv = (uv - vec2(GRAPH_X, GRAPH_Y)) / vec2(GRAPH_WIDTH, GRAPH_HEIGHT);
    
    // If pixel outside of graph, return no color
    if(
        scaled_uv.x > 1.  || scaled_uv.x < 0. ||
        scaled_uv.y > 1.  || scaled_uv.y < 0.
    ) return opt_color(false, vec3(0., 0., 0.));
    
    // Compute X coordinate to sample iChannel0
    ivec2 coords = ivec2(iChannelResolution[0].x * scaled_uv.x, 0.);
    
    // Get sample value from Buffer
    float height = texelFetch(iChannel0, coords, 0).x;
    
    // If pixel isn't graph bar, return background
    if(scaled_uv.y > height)
    {   
        return opt_color(FILL_BACKGROUND, vec3(0.1, 0.1, 0.1));
    }
    
    // Return somewhat of a color blend between blue and orange
    return opt_color(true, vec3(height, height / 4., 1.-height));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    
    vec3 col = vec3(0., 0., 0.);
    
    opt_color colorStruct = getFrameGraphColor(uv);
    if(colorStruct.Ok) col = colorStruct.color; // Checking if color should be used
    
    
    // -----------------------------------------
    // Stress test to lower fps. Change maxI if needed
    float a = 0.;
    float maxI = 4500.;
    for(float i = 0.; i < maxI; i++)
    {
        a += sqrt(dot(vec3(0.5, i, pow(i, 2.)), vec3(i, 1., 1.)));
    }
    // Use `a` for something, else the code is optimized and the loop is unused
    col.b += a-(a+0.000000000000000001);
    // -----------------------------------------
    
    
        
    // Output to screen
    fragColor = vec4(col,1.0);
}