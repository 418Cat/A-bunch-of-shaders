#define PI 3.141592653589793

// View Settings
#define ZOOM vec2(.1, 0.1)
#define VIEW_OFFSET vec2(0./50., 0.)
#define NORMALIZE true


//  Graphics settings
/**/#define DRAW_WIDTH 1.

/**/#define FUNCTION_STATIC false
/**/#define FUNCTION_FILL true

/*  Only if FUNCTION_STATIC is false          */
/*  */#define FUNCTION_SPEED 5.
/*    Trail Settings                            */
/*    */#define FUNCTION_TRAIL true
/*    */#define FUNCTION_TRAIL_FADE true
/*    */#define FUNCTION_TRAIL_FADE_SPEED 0.9
/*    */#define FUNCTION_TRAIL_WRAP true


// Function to be displayed
float func(float x)
{
    float ampl =  .5;
    float per  =  2.;
    float len  =  1.;
    
    float freq = 1. / per;
    float sum = ampl * len/per;
    float fact = 2.*ampl  / PI;
    
    for(int i = 1; i <= 13; i++)
    {
        float f_i = float(i);
        sum += 1. *
        (
            (1. / f_i) *
            sin(PI * f_i * len / per)  *
            cos(2.*PI * f_i * freq * x)
        );
    }
    
    return sum - ampl / 2.;
}