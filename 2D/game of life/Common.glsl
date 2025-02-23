/*
    Viewport zoom
    The viewport is finite, a
    value < 1 will show its limits
    
    Cells outside of the viewport
    aren't computed for optimisation
*/
#define ZOOM 5.


// Mouse brush
#define BRUSH_SIZE 5.
/*
    If set to false, the brush
    will set all cells within
    BRUSH_SIZE distance to 1
 */
#define RANDOM_FILL true


// How fast the pixels turn blue
#define DECAY_SPEED .01

// Game settings
#define OVERPOP 3.
#define UNDERPOP 2.
#define SPAWN 3.

// Pretty explicit name
#define MAX_FPS 20.

// Spawn random cells at start
#define RANDOM_START false

// Hash function to generate the random start
float pcg_hash(float n)
{
    uint state = uint(n * 747796405.) + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return float((word >> 22u) ^ word);
}
