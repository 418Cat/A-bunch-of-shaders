HitRecord sphere_intersect(Ray r, Sphere s, Interval i)
{
    vec3 V = s.center - r.origin;
    
    float a = dot(r.direction, r.direction);
    float h = dot(V, r.direction);
    float b = -2.*h;
    float c = dot(V, V) - s.radius*s.radius;
    
    float discr = h*h - a*c;
    
    // No root so no intersection
    if(discr < 0.)
    {
        return HitRecord(false,
            0.,
            vec3(0., 0., 0.),
            vec3(0., 0., 0.),
            s.material);
    }
    
    float sqrt_discr = sqrt(discr);
    
    // If the closest root is outside of range, try the other
    float root = (h - sqrt_discr) / a;
    if(root < i.t_min || root > i.t_max)
    {
        root = (h + sqrt_discr) / a;
        
        if(root < i.t_min || root > i.t_max)
        {
            // No root in range given, return false
            return HitRecord(false,
                0.,
                vec3(0., 0., 0.),
                vec3(0., 0., 0.),
                s.material);
        }
    }
    
    vec3 hit_point = r.origin + root*r.direction;
    vec3 normal = hit_point - s.center;
    normal = normal / s.radius; // Normalize the normal vec
    
    return HitRecord(true, root, hit_point, normal, s.material);
}

vec3 gamma_correction(vec3 linear)
{
    float r = sqrt(linear.r);
    float g = sqrt(linear.g);
    float b = sqrt(linear.b);
    
    return vec3(r, g, b);
}

vec3 rand_unit_vec(vec2 xy, float seed)
{
    float a = rnd(xy, seed+0.1);
    float b = rnd(xy, seed+0.2);
    float c = rnd(xy, seed+0.3);
    
    vec3 v = vec3(a, b, c);
    return v;
}

// Passing the coordinates for the random number generator
vec3 ray_color(Ray r, vec2 coords)
{
    const int spheres_length = 5;
    
    Sphere[spheres_length] spheres = Sphere[]
    (
        Sphere(vec3(0., 0., 3.), .5, Material(vec3(.8, 0.6, 0.6), DIFFUSE)),
        Sphere(vec3(-1., 0., 3.), .3, Material(vec3(0.9, .8, 0.2), MIRROR)),
        Sphere(vec3(1., 0., 3.), .3, Material(vec3(0., 0., 1.), MIRROR)),
        Sphere(vec3(0., -100.5, 0.), 100., Material(vec3(0., 0., 1.), DIFFUSE)),
        Sphere(vec3(cos(iTime)*1., 1., 3.+sin(iTime)*1.), .4, Material(vec3(1., 0., 0.), MIRROR))
    );
    
    HitRecord hr;
    
    vec3 col = vec3(0., 0., 0.);
    
    Ray current_ray = r;
    
    float ray_i = 1.;
    
    
    // Ray depth loop
    for(ray_i = 1.0; ray_i <= 10.; ray_i++)
    {
        hr = HitRecord(
                false,
                1.e10,
                vec3(0., 0., 0.),
                vec3(0., 0., 0.),
                spheres[0].material
                );
        
        // Get closest hit point
        for(int sphere_i = 0; sphere_i < spheres_length; sphere_i++)
        {
            HitRecord tmp_hr =
                sphere_intersect(
                    current_ray,
                    spheres[sphere_i],
                    Interval(0.001, hr.t)
                );
                
            if(tmp_hr.hasHit) hr = tmp_hr;
        }
        
        /*
            If the ray has hit a sphere,
            add sphere color and reflect
            else add the sky and break out
        */
        if(hr.hasHit)
        {
            if(hr.material.type == DIFFUSE)
            {
                /*
                    Generate a random vec and turn
                    it if it's facing the wrong way
                */
                vec3 rand_v = rand_unit_vec(coords, fract(iTime));
                if(dot(rand_v, hr.normal) < 0.) rand_v = -rand_v;
                
                current_ray = Ray(hr.point, rand_v);
            }
            if(hr.material.type == MIRROR)
            {
                // Reflect
                vec3 reflected_r = reflect(current_ray.direction, hr.normal);
                
                current_ray = Ray(hr.point, reflected_r);
            }
            
            col += hr.material.color * pow(0.5, ray_i);
        }
        else
        {
            /*
                Sky color shamelessly stolen from the
                book "Ray Tracing in One Weekend"
            */
            vec3 unit_direction = current_ray.direction/length(current_ray.direction);
            float a = 0.5*(unit_direction.y + 1.0);
            col += (1.0-a)*vec3(1.0, 1.0, 1.0) + a*vec3(0.5, 0.7, 1.0);
            
            break;
        }
    }
    
    // Get the average color
    col /= float(ray_i);
    
    return col;
}

// Maps the pixel coordinates from -0.5 to 0.5;
vec2 toUv(vec2 coords)
{
    return vec2(coords/iResolution.xy) - vec2(0.5, 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = toUv(fragCoord);
    
    float aspect_ratio = iResolution.x/iResolution.y;
    vec2 viewport_size = vec2(aspect_ratio, 1.);
    vec2 pixel_delta = viewport_size / iResolution.xy;
    
    vec3 view_vector = vec3(viewport_size * uv, 1.);
    
    // Rotation matrix, unused for now
    mat3 rotation = mat3(
        1., 0., 0.,
        0., 1., 0.,
        0., 0., 1.
    );
    
    view_vector *= rotation;
    
    vec3 camera_point = vec3(0., 0., 0.);
    
    Ray view_ray = Ray(camera_point, view_vector);
    
    vec3 col = vec3(0., 0., 0.);
    
    // Multi-sampling loop
    float i = 0.;
    for(i = 0.; i < 10.; i++)
    {
        // Random sub-pixel offset for view_vector
        vec2 offset = vec2(
                        (pixel_delta.x) * rnd(fragCoord, fract(iTime+0.1)),
                        (pixel_delta.y) * rnd(fragCoord, fract(iTime+0.2))
        );
        
        /*
            Generating a vec2 which depends on
            the iteration number, else each 
            pseudo-random number generated will
            be the same per frame so multi-sampling
            won't work
        */
        vec2 rng_seed = fragCoord + vec2(rnd(-fragCoord, i), rnd(fragCoord.yx, -i));
    
        col += ray_color(
                    Ray(camera_point,
                        view_vector + vec3(offset, 0.)),
                    rng_seed
        );
    }
    

    // Output to screen
    fragColor = vec4(col / i,1.0);
}