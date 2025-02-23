/*
    CELL STRUCTURE:
    
    alive (0/1)
    lifetime
    last iTime update
    initialized (0/1)
*/

vec4 last_state(vec2 fragCoord)
{
    return texelFetch(iChannel0, ivec2(fragCoord), 0);
}

float next_state(float last, float n)
{
    float delta = 0.; // Unused

    // n in [UNDERPOP, OVERPOP] and was alive
    float lives = step(UNDERPOP, n         +delta) +
                  step(n       , OVERPOP-1.+delta) +
                  step(1.      , last      +delta) -2.;
    
    // n equal to SPAWN
    float spawns = step(n, SPAWN+delta) +
                   step(SPAWN, n+delta) - 1.;

    return max(lives, spawns);
}

float n_neighbours(vec2 fragCoord)
{
    float neighbours = 0.;
    
    // Meh
    neighbours += last_state(fragCoord + vec2(1., 1.)).x;
    neighbours += last_state(fragCoord + vec2(0., 1.)).x;
    neighbours += last_state(fragCoord + vec2(-1., 1.)).x;
    
    neighbours += last_state(fragCoord + vec2(1., 0.)).x;
    neighbours += last_state(fragCoord + vec2(-1., 0.)).x;
    
    neighbours += last_state(fragCoord + vec2(1., -1.)).x;
    neighbours += last_state(fragCoord + vec2(0., -1.)).x;
    neighbours += last_state(fragCoord + vec2(-1., -1.)).x;
    
    return neighbours;
}

float random_state(vec2 seed)
{
    return step(10., mod(pcg_hash(seed.x/(seed.y+seed.x)), 10.));
}

// Mouse brush
float is_painted(vec2 fragCoord)
{
    // distance to mouse if clicked
    float cell = distance(iMouse.xy / ZOOM, fragCoord*sign(iMouse.z));
    
    // Returns cells within BRUSH_SIZE distance
    // to mouse, and kill random cells if RANDOM_FILL
    return step(
        cell,
        BRUSH_SIZE
    ) *
    (RANDOM_FILL ? random_state(fragCoord*iTimeDelta*10.) : 1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Return early if cell is outside the viewport
    if(
        fragCoord.x > iChannelResolution[0].x / ZOOM ||
        fragCoord.y > iChannelResolution[0].y / ZOOM
    ) return;
    
    vec4 current_state = last_state(fragCoord);
    
    // If cell hasn't been initialized
    if(current_state.w < 1.)
    {
        float alive = 0.;
        
        if(RANDOM_START) alive = random_state(fragCoord);
        
        current_state = vec4(
            alive,
            0.,
            iTime,
            1.
        );
    }
    
    
    // Time to update
    if(iTime - current_state.z >= 1./MAX_FPS)
    {
        float next = next_state(current_state.x, n_neighbours(fragCoord));
        
        current_state = vec4(
            next,
            next == 1. ? current_state.y+1. : 0., // Add 1 to lifetime if is alive
            iTime,
            1.
        );
    }
    
    // cell is alive or is painted
    current_state.x = max(current_state.x, sign(iMouse.z)*is_painted(fragCoord));

    fragColor = current_state;
}
