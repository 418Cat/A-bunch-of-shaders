#define COLORS  false
#define BORDERS true

bool isInInterval(vec2 interval, float n)
{
    return n >= interval.x && n <= interval.y;
}

bool isInSquareInterval(vec4 interval, vec2 point)
{
    return isInInterval(interval.xz, point.x) && isInInterval(interval.yw, point.y);
}

bool isOnSquareBoundaries(vec4 interval, vec2 point, vec2 delta)
{
    return isInInterval(vec2(interval.x-delta.x, interval.x+delta.x), point.x) ||
           isInInterval(vec2(interval.z-delta.x, interval.z+delta.x), point.x) ||
           isInInterval(vec2(interval.y-delta.y, interval.y+delta.y), point.y) ||
           isInInterval(vec2(interval.w-delta.y, interval.w+delta.y), point.y);
}

vec3 hsvToRgb(float h, float s, float v)
{
    float c = s*v;
    float x = c * (1. - abs(mod(h / 60., 2.) - 1.));
    h = mod(h, 360.);
    
    vec3 rgb = vec3(c, x, 0.);
    
    if(isInInterval(vec2(0.  , 60. ), h)) return rgb.rgb;
    if(isInInterval(vec2(60. , 120.), h)) return rgb.grb;
    if(isInInterval(vec2(120., 180.), h)) return rgb.brg;
    if(isInInterval(vec2(180., 240.), h)) return rgb.bgr;
    if(isInInterval(vec2(240., 300.), h)) return rgb.gbr;
    if(isInInterval(vec2(300., 360.), h)) return rgb.rbg;
}

vec4 getSquareInterval(vec2 uv, vec2 subdivisions)
{
    vec2 intervalStart = floor(uv * subdivisions) / subdivisions;
    vec4 interval = vec4(intervalStart, intervalStart + vec2(1., 1.)/subdivisions);
    
    return interval;
}

vec3 gammaCorrection(vec3 linear)
{
    float gammaFactor = 0.5;

    return vec3(
        pow(linear.r, gammaFactor),
        pow(linear.g, gammaFactor),
        pow(linear.b, gammaFactor)
    );
}

vec2 toUv(vec2 fragCoord)
{
    return fragCoord / iResolution.x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = toUv(fragCoord);
    
    vec3 col = vec3(0., 0., 0.);
    
    // Initial subdivision;
    vec2 subdivisions = vec2(1., 1.);
    
    float maxIter  = 20.;
    float hueSpeed = 10.;
    float hueShift = iTime*10.;
    
    for(float i = 0.; i < maxIter; i++)
    {
        vec4 interval = getSquareInterval(uv, subdivisions);
         
        // Mouse is in current quadrant
        if(isInSquareInterval(interval, toUv(iMouse.xy)))
        {
            // Draw full square with color
            if(COLORS) col = hsvToRgb(i*hueSpeed+hueShift, .7, 1.);
             
            // Draw borders
            if(BORDERS)
            {    
                vec2 halfInterval = (interval.zw - interval.xy)/2.;
                
                // Check if pixel is on edge of 2 half-squares to draw the middle lines
                if(
                    isOnSquareBoundaries(vec4(interval.x, interval.y, interval.z, interval.y+halfInterval.y), uv, toUv(vec2(.0, .5))) ||
                    isOnSquareBoundaries(vec4(interval.x, interval.y, interval.x+halfInterval.x, interval.w), uv, toUv(vec2(.5, .0)))
                )
                {
                    if(COLORS) col = vec3(0., 0., 0.);
                    else       col = vec3(1., 1., 1.);
                }
            }
        }         
        subdivisions *= 2.;
    }
    
    fragColor = vec4(gammaCorrection(col),1.0);
}