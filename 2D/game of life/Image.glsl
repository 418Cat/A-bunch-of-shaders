vec4 get_cell(vec2 uv)
{
    // X coordinate to sample iChannel0
    vec2 coords = vec2(iChannelResolution[0])*uv/ZOOM;
    
    return texelFetch(iChannel0, ivec2(coords), 0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    // Get corresponding cell value
    vec4 cell = get_cell(uv);
    
    vec3 col = vec3(cell.x);
    
    // Set decay color
    col.rg = vec2(cell.x - cell.y*DECAY_SPEED);
    
    fragColor = vec4(col, 1.);
}
