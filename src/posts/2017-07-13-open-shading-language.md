<!--
{
  "title": "Open Shading Language",
  "date": "2017-07-13T20:36:21+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Building from source

```
$ mkdir -p out/Default/_install
$ cd out/Default
# somehow there's compile error if I used gcc, so blindly I switched to clang
$ cmake -G Ninja -DCMAKE_INSTALL_PREFIX=$PWD/_install -DSTOP_ON_WARNING=OFF \
                 -DCMAKE_BUILD_TYPE=Debug -DOPENIMAGEIOHOME=/ ..
$ ninja -j4 install
$ ninja test # testsuite requires python 2

# Run single test
$ ctest -V -R render-oren-nayar.opt
test 217
    Start 217: render-oren-nayar.opt

217: Test command: /usr/sbin/env "TESTSHADE_OPT=2" "OPENIMAGEIOHOME=/" "python" "/home/hiogawa/code/others/OpenShadingLanguage/out/Default/testsuite/runtest.py" "/home/hiogawa/code/others/OpenShadingLanguage/out/Default/testsuite/render-oren-nayar"
217: Test timeout computed to be: 1500
217: Comparing "out.exr" and "ref/out.exr"
217: PASS
217: test source dir = ../../../../testsuite/render-oren-nayar
217: command = ../../src/oslc/oslc checkerboard.osl >> out.txt 2>&1 ;
217: ../../src/oslc/oslc emitter.osl >> out.txt 2>&1 ;
217: ../../src/oslc/oslc matte.osl >> out.txt 2>&1 ;
217: ../../src/oslc/oslc rough_matte.osl >> out.txt 2>&1 ;
217: ../../src/testrender/testrender  -v --stats -r 320 240 -aa 4 scene.xml out.exr >> out.txt 2>&1 ;
217:
217: PASS: out.exr matches ref/out.exr
1/1 Test #217: render-oren-nayar.opt ............   Passed    2.15 sec

# Without runtes.py wrapper
$ cd ./testsuite/render-oren-nayar
$ ../../src/testrender/testrender -v --stats -r 320 240 -aa 4 scene.xml out.tif
```


# Overview of testrender

Here "testsuite/render-oren-nayar" is assuemed as an example.

```
[ Data structure ]
camera
std::vector<ShaderGroupRef> shaders

ShaderGroup
'-' RunLLVMGroupFunc m_llvm_compiled_init
'-* RunLLVMGroupFunc (m_llvm_compiled_layers)
'-* ShaderInstance (m_layers)
  '-' ShaderMaster::ref
  '-' SymbolVec m_instsymbols
  '-' OpcodeVec m_instops
  '-* Connection (m_connections)
    '-' int srclayer
    '-' ConnectedParam src, dst
  '-' SymOverrideInfoVec m_instoverrides

ShaderMaster
'-' OpcodeVec m_ops
'-' std::vector<int> m_args
'-' SymbolVec m_symbols

ClosureRegistry
'-* ClosureEntry
  '-' id, name, and parameters
  '-' PrepareClosureFunc (TODO: for what kind of purpose)
  '-' SetupClosureFunc   (TODO: )

ShadingResult
'-' Color3
'-' CompositeBSDF (flatten representation of closures, which generated from Ci (ClosureColor) via process_closure)
  '-* Color3 (weights)
  '-* float  (pdfs)
  '-* BSDF   (psdfs)


[ Procedure ]

(Main thread)
- main =>
  - new ShadingSystem => new ShadingSystemImpl ..
  - register_closures =>
    - ShadingSystem::register_closure (e.g. "oren_nayar" , OREN_NAYAR_ID, { .. Vec3 N; float sigma } ) =>
      - ShadingSystemImpl => ClosureRegistry::register_closure => ..
  - parse_scene =>
    - (Camera setup) camera = Camera ..
    - (Object setup) Scene::add_sphera(..  int(shaders.size()) - 1)
    - (Shader setup)
      - ShaderGroupRef group = ShadingSystem::ShaderGroupBegin( .. commands) => (impl) =>
        - new ShaderGroup
        - (.. Parse ShaderGroup statements ..)
        - (case "param color Ca 0.1 0.1 0.1") Parameter("Ca", TypeDesc::TypeColor, [0.1, ..]) =>
          - m_pending_params.back().init (i.e. ParamValue::init) ..
        - (case "shader checkerboard tex") Shader("surface", "checkerboard", "tex") =>
          - master = loadshader("checkerboard") =>
            - OSOReaderToMaster::parse_file (read "checkerboard.oso" and allocate ShaderMaster) =>
              - OSOReader::parse_file => osoparse (entry to Bison (osogram.y) and flex (osolex.l)) ..
            - ShaderMaster::resolve_syms => ..
          - new ShaderInstance(master, "tex")
          - ShaderInstance::parameters(m_pending_params) =>
            - (initialize parameter using master default or previous "param" statements) ..
          - ShaderGroup::append(instance)
        - (case "connect tex.Cout layer1.Cs") ConnectShaders("tex", "Cout", "layer1", "Cs") =>
          - ShaderInstance srcinst, dstinst (for "tex" and "layer1")
          - ConnectedParam srccon, dstcon (for "Cout" and "Cs")
          - ShaderInstance::add_connection(srcinstindex, srccon, dstcon) => ..
      - ShadingSystem::ShaderGroupEnd => ..
      - shaders.push_back (group)
  - std::vector<Color3> pixels
  - OIIO::ImageBuf pixelbuf
  - OIIO::thread_group::add_thread(new std::thread (scanline_worker ..)) => (SEE BELOW)
  - OIIO::thread_group::join_all
  - OIIO::ImageBuf::write


(Raytracing thread)
- scanline_worker => antialias_pixel => subpixel_radiance =>
  - Color3 path_weight(1, 1, 1)
  - Color3 path_radiance(0, 0, 0)
  - float bsdf_pdf = std::numeric_limits<float>::infinity()
  - (loop at most max_bounces times)
    - Scene::intersect => ..
    - globals_from_hit(ShaderGlobals sg, ..) => ..
    - ShadingSystem::execute =>
      - ShadingSystemImpl, ShadingContext::execute(ShaderGroup &sgroup, ShaderGlobals &ssg ..) =>
        - execute_init =>
          - ShadingSystemImpl::optimize_group =>
            - RuntimeOptimizer rop, rop.run => (oso code level optimization since now we have instantiated parameters ?)
            - BackendLLVM lljitter, lljitter.run => (SEE BELOW (Jitting))
          - call jitted ShaderGroup::llvm_compiled_init => ..
        - execute_layer =>
          - call jitted function ShaderGroup::llvm_compiled_layer => ..
    - process_closure(ShadingResult result, ClosureColor* sg.Ci, ..) => process_closure =>
      - (traverse ClosureColor tree and get flatten representation CompositeBSDF)
      - result.Le += .. if ClosureComponent is emission
      - CompositeBSDF::add_bsdf (as result.bsdf.add_bsdf) ..
    - path_radiance += path_weight * k * result.Le
    - CompositeBSDF::prepare (as result.bsdf.prepare) => .. (some normalization ?)
    - (for each direct lights (aka Primitive which islight))
      - Vec3 ldir = Scene::sample => ..
      - Color3 contrib = path_weight * ... * CompositeBSDF::eval (as result.bsdf.eval) =>
        - BSDF::eval (e.g. Diffuse::eval) ..
      - .. light shader execution and process_closure
      - path_radiance += contrib * light_result.Le
    - path_weight *= CompositeBSDF::sample (as result.bsdf.sample) =>
      - (for each BSDF from CompositeBSDF::bsdfs)
        - BSDF::sample (e.g. Diffuse::sample)  
  - return path_radience


(Jitting)
- BackendLLVM::run =>
  - LLVM_Util::module_from_bitcode( .. "llvm_ops" ..) => (load llvm_ops.cpp as llvm bytecode module)
  - LLVM_Util::make_jit_execengine => (alloc llvm::ExecutionEngine)
  - initialize_llvm_group =>
    - LLVM_Util::setup_optimization_passes ..
    - initialize_llvm_helper_function =>
      - DECL(name,signature) (e.g. DECL(osl_add_closure_closure, "CXCC")) =>
        - llvm_helper_function_map["osl_add_closure_closure"] = HelperFuncRecord("CXCC", osl_add_closure_closure)
        - external_function_names.push_back("osl_add_closure_closure"])
  - std::vector<llvm::Function*> funcs
  - (for each layer)
    - funcs[layer] = build_llvm_instance => (llvm IR gen)
  - ShaderGroup::llvm_compiled_init(LLVM_Util::getPointerToFunction(init_func))
  - (for each layer)
    - ShaderGroup::llvm_compiled_layer(.. LLVM_Util::getPointerToFunction(funcs[layer]))


(Jitted code example: builtin operation)
- ClosureAdd * osl_add_closure_closure(ShaderGlobals *sg, ClosureColor *a, ClosureColor *b) =>
  - ShadingContext::closure_add_allot =>
    - ClosureAdd *add = SimplePool::alloc ..
    - add->id = ClosureColor::ADD
    - add->closureA = a
    - add->closureB = b
```


# Flex and Bison

- osolex.l => osolex.cpp (defines osolex as yylex)
- osogram.y => osogram.cpp, osogram.hpp (defines osoparse as yyparse)


# TODO

- sample vs eval
  - how is "eval" part executed for indirect light path ?
      - maybe this testrender implementation doesn't consider this
        as blender cycles configuration can be also setup in that way.
        (TODO: follow cycles' non-direct-light-only diffuse eval case)
- compile error when -DCMAKE_BUILD_TYPE=Debug
  - #include <atomic> in liboslccomp/ast.cpp
  - Strutil::printf (am i using wrong OIIO ?)
- 'ctest -V -R render-oren-nayar.opt' fails for debug build
- how exactly is "closure" represented in llvm jitted code ?
  - operation on closure (ClosureColor tree construction)
  - from OSL spec (5.10 Closures), note that there's no binary multiplication of two closures.


# References

- https://github.com/imageworks/OpenShadingLanguage
- Blender cycles integration ([my code reading](./2017-07-08-blender-cycles.html))
