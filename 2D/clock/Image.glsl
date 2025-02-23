#define THICKNESS 0.0015
#define SNAP_SECONDS false

// Replace iDate.w by iTime to have a timer
#define TIME iDate.w

#define PI 3.1415926


float rotation(vec2 xy) //between 0 and 1, starts at the top and goes clockwise
{
    return mod(atan(xy.x, xy.y), 2.0*PI) / (2.0*PI);
}

float isTargetAngle(float angle, float targetAngle)
{
    return step(abs(angle - targetAngle), THICKNESS);
}

vec2 normalizeCoords(vec2 xy)
{
    vec2 uv = xy / iResolution.x;
    return uv - vec2(0.5, 0.5 * iResolution.y / iResolution.x);
}

float isHand(vec2 xy, float timeDivider, float size)
{
    float angle = rotation(xy);
    if(SNAP_SECONDS)
    {
        return
            isTargetAngle(angle, floor(fract(TIME/timeDivider) * timeDivider) / timeDivider)
            *
            step(length(xy), size);
    }

    return
        isTargetAngle(angle, fract(TIME / timeDivider))
        *
        step(length(xy), size);
}

float isMarks(vec2 xy, float timeDivider, vec2 sizeLimits)
{
    float angle = rotation(xy);
    
    float mask = 0.;
    
    for(float i=0.; i<timeDivider; i+=1.)
    {
        mask = max(mask, 
            isTargetAngle(angle, i / timeDivider)
            *
            step(length(xy), sizeLimits.y)*step(sizeLimits.x, length(xy))
            );
    }

    return mask;
}

vec3 getCol(vec2 uv)
{
    vec3 col = vec3(0., 0., 0.);
    
    col.gb += isHand(uv, 60., 0.3);            // Seconds hand
    col.rb += isHand(uv, 3600., 0.25);         // Minutes hand
    col.rg += isHand(uv, 3600. * 12., 0.2);    // Hours   hand
    
    // Return early so the hands appear over the marks
    if(col != vec3(0., 0., 0.)) return col;
    
    col += isMarks(uv, 60., vec2(0.30, 0.33)); // Seconds mark
    col += isMarks(uv, 60., vec2(0.25, 0.27)); // Minutes mark
    col += isMarks(uv, 12., vec2(0.20, 0.21)); // Hours   mark
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = normalizeCoords(fragCoord) / 0.8;
    vec2 adjacentUv = normalizeCoords(fragCoord+0.5) / 0.8;
    
    // Get average color to smooth out
    vec3 col = getCol(uv);
    col += smoothstep(
        0.,
        1., getCol(adjacentUv)-getCol(uv));

    // Output to screen
    fragColor = vec4(col ,1.0);
}
