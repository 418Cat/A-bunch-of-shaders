# Shaders
Shaders are programs running on the GPU. The programming style is very different from typical programming,
as on shadertoy the code is ran for each pixel (This type of shaders is called Fragment Shaders).
Shadertoy allows for fragment shaders to be written and ran in a browser thanks to WebGL.

<br>
<br>

## What is this ?
This repository is a collection of shaders I have written for shadertoy. The shaders are pretty simple and are made purely out of curiosity as POCs.
<br>
Shaders are sorted in the `./3D` and `./2D` folders depending on the type of scene they represent.
<br>
<br>

## This repo's shaders list:
- 2D:
  - [Quadtree visualizer](https://www.shadertoy.com/view/4X3BRr)
 <br>
&emsp; Moving the mouse changes how the quadtree is built
![quadtree image](https://raw.githubusercontent.com/418Cat/A-bunch-of-shaders/refs/heads/main/images/quadtree_visualizer.png)
<br>

  - [Function visualizer](https://www.shadertoy.com/view/XfVcz3)
<br>
&emsp; Displays 2D real functions with a bunch of options
![square function image](https://raw.githubusercontent.com/418Cat/A-bunch-of-shaders/refs/heads/main/images/function_visualizer.png)
<br>

  - [Real Time Clock](https://www.shadertoy.com/view/43KBWR)
<br>
&emsp; One of my first shaders made using trigonometry and some glsl math functions
![real time clock image](https://raw.githubusercontent.com/418Cat/A-bunch-of-shaders/refs/heads/main/images/real_time_clock.png)
<br>

  - [FPS Graph](https://www.shadertoy.com/view/X3tBWr)
<br>
&emsp; A configurable & easy to integrate shader to show the scene's performance history
![fps graph image](https://raw.githubusercontent.com/418Cat/A-bunch-of-shaders/refs/heads/main/images/fps_graph.png)
<br>

  - [Game of life](https://www.shadertoy.com/view/lXKBRy)
<br>
&emsp; Conway's game of life, a 2D cellular automaton bound by simple rules but showing complex behaviors
![Game of life image](https://raw.githubusercontent.com/418Cat/A-bunch-of-shaders/refs/heads/main/images/game_of_life.png)
<br>

- 3D:
  - [Very simple ray tracer](https://www.shadertoy.com/view/M3KcRw)
<br>
&emsp; A basic ray tracer wrote in a few hours after reading the great [Ray tracing in one weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
![Ray tracing image](https://raw.githubusercontent.com/418Cat/A-bunch-of-shaders/refs/heads/main/images/very_simple_ray_tracer.png)

___
All the code in this repo is under the MIT Licence.
