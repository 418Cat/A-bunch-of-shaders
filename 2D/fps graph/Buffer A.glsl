// get the sample on the right of the current pixel
float getNextSample(vec2 fragCoord)
{
    return texelFetch(iChannel0, ivec2(fragCoord.xy) + ivec2(1., 0.), 0).x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // only pixels of coord (X, 0) are used
    if(fragCoord.y >= 1.) return;
    
    float value = 0.;
    
    // If current pix is the right-most one, set to new value
    if(fragCoord.x >= iChannelResolution[0].x - 1.)
    {
        value = min(iTimeDelta / MAX_FRAME_TIME, 1.);
    }
    
    // Else get the value from its right neighbour
    else
    {
        value = getNextSample(fragCoord);
    }
    
    fragColor = vec4(value, 0., 0., 0.);
}