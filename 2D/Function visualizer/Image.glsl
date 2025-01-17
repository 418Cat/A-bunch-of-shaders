// Constant defined later, represents how big
// a screen pixel is in UV coords
vec2 DELTA;

/*
 * Centered on the origin
 * from -.5 to .5 for X
 * normalized for Y, from negative to positive too
 */
vec2 pixToUv(vec2 pix)
{
    float x = pix.x / iResolution.x - .5;
    
    float y;
    if(NORMALIZE)
    {
        y = (pix.y - iResolution.y / 2.) / iResolution.x;
    }
    else
    {
        y = pix.y / iResolution.y - 0.5;
    }
    
    x += VIEW_OFFSET.x;
    y += VIEW_OFFSET.y;
    
    x /= ZOOM.x;
    y /= ZOOM.y;
    
    
    return vec2(x, y);
}


/*
 * returns true if the distance between
 * the uv coord and the point is < to
 * the delta distance
 */
bool uvIsPoint(vec2 uv, vec2 point)
{
    return abs(uv.x - point.x) <= (DELTA.x * DRAW_WIDTH / 2.) &&
           abs(uv.y - point.y) <= (DELTA.y * DRAW_WIDTH / 2.);
}

bool uvIsBetween(){return true;}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    // Normalized, zoomed and offset
    vec2 uv = pixToUv(fragCoord);
    
    vec2 topRightPixUV = pixToUv(fragCoord + vec2(1., 1.));
    DELTA = abs(topRightPixUV - uv);
    
    float time_x = VIEW_OFFSET.x / ZOOM.x + (mod(iTime*FUNCTION_SPEED, 1. / ZOOM.x) - (0.5 / ZOOM.x));
    
    float r = 0.;
    float g = 0.;
    float b = 0.;
    
    // draw grid
    if(uvIsPoint(uv, vec2(uv.x, 0.))) r = 0.7;
    if(uvIsPoint(uv, vec2(0., uv.y))) r = 0.7;
    
    float y = func(uv.x);
    float yNext = func(uv.x + DELTA.x);
    
    if(FUNCTION_STATIC)
    {
        if(uvIsPoint(uv, vec2(uv.x, y)))
        {
            g = 1.;
        }
        
        if(FUNCTION_FILL && ((uv.y >= y && uv.y <= yNext) || (uv.y <= y && uv.y >= yNext)))
        {
            g = 1.;
        }
    }
    
    if(!FUNCTION_STATIC)
    {
    
        // If X is withing (time_ax +- DELTA.x)
        if(uv.x < time_x+DELTA.x && uv.x > time_x-DELTA.x)
        {
            // If point is on curve
            if(uvIsPoint(uv, vec2(uv.x, y))) g = 1.;
            
            // If point is located between two samples
            if(FUNCTION_FILL &&
                (uv.y >= y && uv.y <= yNext ^^
                 uv.y <= y && uv.y >= yNext)) g = 1.;
        }
        
        if(FUNCTION_TRAIL)
        {
            float tmp_time_x = time_x;
            bool DRAW_X = false;
            bool DRAW_POINT = false;
            
            // If trail wrap and X is ahead
            DRAW_X = FUNCTION_TRAIL_WRAP && uv.x > time_x+DELTA.x;
            
            // set time_x to 1 screen ahead to have it wrap
            if(DRAW_X) tmp_time_x += DELTA.x * iResolution.x;
            
            DRAW_X = DRAW_X || uv.x < tmp_time_x-DELTA.x;
            
            // If point is located between two samples
            DRAW_POINT = FUNCTION_FILL &&
                (uv.y >= y && uv.y <= yNext ^^
                 uv.y <= y && uv.y >= yNext) && DRAW_X;
            
            DRAW_POINT = DRAW_POINT || (DRAW_X && uvIsPoint(uv, vec2(uv.x, y)));
            
            if(DRAW_POINT) g = 1.;
            
            // If trail fade enabled
            if(FUNCTION_TRAIL_FADE)
            {
                g *= 1.- FUNCTION_TRAIL_FADE_SPEED*(tmp_time_x - uv.x);
            }
        }
    }
    

    // Output to screen
    fragColor = vec4(r, g, b, 1.0);
}