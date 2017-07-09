<!--
{
  "title": "Blender Cycles",
  "date": "2017-07-08T08:49:31+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# TODO

- [x] main path
- [ ] theory
  - ray tracing configuration
      - sampling rays
      - tiling
  - BVH
  - shader, shader graph, shader node
- [ ] on gpu (opencl)


# Build

```
$ mkdir -p out/Debug/_install
$ cd out/Debug
$ cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ../..
$ ninja -j2
$ ./bin/cycles ../../examples/scene_cube_surface.xml
```


# Overview

```
[ Data structure ]
Session
'-' SessionParams
  '-' DeviceInfo
  '-' int samples
  '-' ShadingSystem
'-' CPUDevice (< Device)
'-' TileManager
'-' session_thread
'-' Scene

Scene
  '-' SceneParams
    '-' ShadingSystem
    '-' bvh_type
  '-' Camera
  '-' Background
  '-* Mesh, Shader, ..
  '-' default_surface, default_light, ..
  '-' Film ??
  '-' DeviceScene
    '-' bvh_nodes
    '-' ..
  '-' ShaderManager

Shader
'-' ShaderGraph
  '-* Node

Node > Camera
     > Object
     > ShaderNode > OutputNode
                  > .. > DiffuseBsdfNode

NodeType
'-* SocketType inputs
'-* SocketType outputs

SockerType
'-' Type (e.g. Color, Vector, CLOSURE, ..)

Ray
'-' P (position)
'-' D (distance)
'-' t (length)

PathRadiance
'-' emission
'-' (__SHADOW_TRICKS__) path_total, path_total_shaded ..
'-' (__PASSES__) indirect/direct, glossy, diffuse ...
'-' (__DENOISING_FEATURES__) ..

(example node)
DiffuseBsdfNode (< BsdfNode < BsdfBaseNode < ShaderNode < Node)
'-' roughness    (as DiffuseBsdfNode)
'-' color        (as BsdfNode)
'-' normal       (as BsdfNode)
'-' ClosureType  (as BsdfBaseNode)
'-* ShaderInput  (as ShaderNode)
'-* ShaderOutput (as ShaderNode)
'-' name         (as Node)
'-' NodeType     (as Node)


[ Node definition example ]

(nodes.h)
class DiffuseBsdfNode .. { SHADER_NODE_CLASS(DiffuseBsdfNode) .. }
 ||
 ||  (macro: SHADER_NODE_CLASS and NODE_DECLARE)
\||/
 \/
class DiffuseBsdfNode .. {
  template<typename T>
  static const NodeType *register_type();

  static Node *create(const NodeType *type);
  static const NodeType *node_type;
	DiffuseBsdfNode();
	virtual ShaderNode *clone() const { return new DiffuseBsdfNode(*this); } \
	virtual void compile(SVMCompiler& compiler); \
	virtual void compile(OSLCompiler& compiler); \
}

(nodes.cpp)
NODE_DEFINE(DiffuseBsdfNode)
{
  NodeType* type = NodeType::add("diffuse_bsdf", create, NodeType::SHADER)
  ..
	SOCKET_IN_COLOR(color, "Color", make_float3(0.8f, 0.8f, 0.8f));
  SOCKET_OUT_CLOSURE(BSDF, "BSDF"); ??
  ..
  return type
}
 ||
 ||  (macro: NODE_DEFINE, SOCKET_IN_COLOR, and SOCKET_DEFINE)
\||/
 \/
const NodeType *DiffuseBsdfNode::node_type = DiffuseBsdfNode::register_type<DiffuseBsdfNode>();

Node *DiffuseBsdfNode::create(const NodeType*) { return new DiffuseBsdfNode(); }    

template<typename T>
const NodeType *DiffuseBsdfNode::register_type() {
  NodeType* type = NodeType::add("diffuse_bsdf", create, NodeType::SHADER)
  ..
	{
		static float3 defval = make_float3(0.8f, 0.8f, 0.8f);
		type->register_input(ustring("color"), ustring("Color"), SocketType::COLOR,
                         SOCKET_OFFSETOF(T, color), &defval, NULL, NULL, SocketType::LINKABLE);
	}
  ..
  return type
}


[ Procedure ]

(main)
- main =>
  - options_parse =>
    - scene_init =>
      - new Scene =>
        - new Camera ..
        - ShaderManager::create =>
          - new SVMShaderManager
          - add_default => create Schene::default_surface, light, background, ..
      - xml_read_file => ..
  - view_main_loop =>
    - glutDisplayFunc(view_display)
    - glutMainLoop

(drawing)
- view_display =>
  - (only for first time)
    - V.initf => session_init =>
      - new Session =>
        - TaskScheduler::init => new thread(.. TaskScheduler::thread_run ..)
        - Device::create => device_cpu_create => new CPUDevice
      - Session::start => new thread(... Session::run ..)
  - V.display => display =>
    - Session::draw => ..
    - view_display_info (draw stats)
  - glutSwapBuffers


(worker thread: DeviceTask::RENDER)
- thread_render(task) =>
  - KernelGlobals *kg = new ..
  - RenderTile tile
  - path_trace(.. tile)
    - float *render_buffer = (float*)tile.buffer
    - (for each sample and for each coordinates on tile x, y)
      - path_trace_kernel()(..) => kernel_cpu_avx2_path_trace (macro KERNEL_FUNCTION_FULL_NAME(path_trace)) =>
        - kernel_path_trace =>
          - Ray ray
          - PathRadiance L
          - kernel_path_trace_setup(.. &ray) =>
            - float filter_u, filter_v
            - path_rng_init( &filter_u, &filter_v) => path_rng_2D => path_rng_1D ..
            - camera_sample(.. filter_u, _v .. ray) =>
              - float raster_x = x + ..
              - float raster_y = y + ..
              - camera_sample_perspective(raster_x, _y .. ray) => .. setup ray (position P, direction D, length t)
          - kernel_path_integrate(.. ray .. &L ..) =>
            - path_radiance_init(L ..) => ..
            - ShaderData sd, emission_sd, PathState state
            - path_state_init(&emission_sd, &state, .. &ray) => ..
            - for(;;) (ray path iteration)
              - Intersection isect
              - bool hit = scene_intersect(.. ray .. &isect ..) =>
                - bvh_intersect (macro BVH_FUNCTION_NAME in bvh_traversal.h) =>
                  - BVH_FUNCTION_FULL_NAME(BVH) => ..(TODO: read theory first)
              - (if hit)
                - kernel_path_surface_bounce (which modifies ray for next iteration) =>
                  - (if SD_BSDF)
                    - float3 bsdf_omega_in
                    - shader_bsdf_sample(.. &bsdf_omega_in ..) => ..
                    - path_radiance_bsdf_bounce => ..
                    - path_state_next
                    - ray->D = normalize(bsdf_omega_in)
                    - ..
              - (otherwise go for background)
                - float3 L_background = indirect_background(kg, &emission_sd, &state, &ray) =>
                  - shader_setup_from_background(.. emission_sd ..) => ..
                  - float3 L = shader_eval_background(.. emission_sd ..) =>
                    - svm_eval_nodes => ... (TODO: closure execution) loop until NODE_END
                - path_radiance_accum_background =>
                - break
            - ..
          - kernel_write_result(.. &L ) =>
            - float3 L_sum = path_radiance_clamp_and_sum(.. L) => ?
            - kernel_write_pass_float4(.. buffer .. value) => *buffer = *buffer + value
            - kernel_write_light_passes(.. buffer .. L) =>
              - kernel_write_pass_float3(buffer + kernel_data.film.pass_diffuse_indirect .. L->indirect_diffuse) => ..
              - ..


(worker thread: DeviceTask::FILM_CONVERT)
TODO: thread_film_convert


(worker thread: DeviceTask::SHADER)
TODO: thread_shader
```


# BVH

```
(bvh_traversal.h)
- BVH_FUNCTION_FULL_NAME(BVH)(.. ray .. isect ..) =>
  - int node_addr = kernel_data.bvh.root
  - (iterate)
    - (find intersecting node)
      - float4 cnodes = kernel_tex_fetch(__bvh_nodes, node_addr+0)
      - int traverse_mask = NODE_INTERSECT( .. node_addr ) => bvh_aligned_node_intersect =>
        - ssef *bvh_nodes = (ssef*)kg->__bvh_nodes.data + node_addr
        - ..
      - node_addr = __float_as_int(cnodes.z)
      - (traverse_mask)
        - ..
    - (if found)
      - float4 leaf = kernel_tex_fetch(__bvh_leaf_nodes, (-node_addr-1))
      - int prim_addr = __float_as_int(leaf.x)
      - (switch by type of primitive)
```


# Shader

TODO: write one or follow one example


# Reference

- https://wiki.blender.org/index.php/Dev:Source/Render/Cycles
- blender integration
  - [my code reading](./2017-06-30-blender.html)
- Computer Graphics: Principles and Practive (Chapter 15. Ray Casting and Rasterization)
