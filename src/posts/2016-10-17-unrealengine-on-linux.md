<!--
{
  "title": "UnrealEngine on Linux",
  "date": "2016-10-17T16:51:25.000Z",
  "category": "",
  "tags": [
    "game"
  ],
  "draft": true
}
-->

- pc/os spec

- commands

there's an third-party build failure for `hlslcc`.

```
$ cat Engine/Build/BatchFiles/Linux/BuildThirdParty.log
building hlslcc
+ cd Source/ThirdParty/hlslcc
+ P4Open hlslcc/lib/Linux/x86_64-unknown-linux-gnu/libhlslcc.a
+ for file in '$@'
+ '[' '!' -e hlslcc/lib/Linux/x86_64-unknown-linux-gnu/libhlslcc.a ']'
+ '[' -w hlslcc/lib/Linux/x86_64-unknown-linux-gnu/libhlslcc.a ']'
+ return
+ cd hlslcc/projects/Linux
+ set +e
++ which clang
+ CLANG_TO_USE=
+ set -e
+ '[' '!' -f '' ']'
+ '[' -e /etc/os-release ']'
+ source /etc/os-release
++ NAME=Ubuntu
++ VERSION='16.04.1 LTS (Xenial Xerus)'
++ ID=ubuntu
++ ID_LIKE=debian
++ PRETTY_NAME='Ubuntu 16.04.1 LTS'
++ VERSION_ID=16.04
++ HOME_URL=http://www.ubuntu.com/
++ SUPPORT_URL=http://help.ubuntu.com/
++ BUG_REPORT_URL=http://bugs.launchpad.net/ubuntu/
++ UBUNTU_CODENAME=xenial
+ [[ debian == \d\e\b\i\a\n ]]
+ [[ 16.04 == \1\6\.\0\4 ]]
+ CLANG_TO_USE=clang-3.8
+ '[' '!' -f clang-3.8 ']'
+ CLANG_TO_USE=clang-3.5
+ set +e
++ which clang++
+ CLANGXX_TO_USE=
+ set -e
+ '[' '!' -f '' ']'
+ '[' -e /etc/os-release ']'
+ source /etc/os-release
++ NAME=Ubuntu
++ VERSION='16.04.1 LTS (Xenial Xerus)'
++ ID=ubuntu
++ ID_LIKE=debian
++ PRETTY_NAME='Ubuntu 16.04.1 LTS'
++ VERSION_ID=16.04
++ HOME_URL=http://www.ubuntu.com/
++ SUPPORT_URL=http://help.ubuntu.com/
++ BUG_REPORT_URL=http://bugs.launchpad.net/ubuntu/
++ UBUNTU_CODENAME=xenial
+ [[ debian == \d\e\b\i\a\n ]]
+ [[ 16.04 == \1\6\.\0\4 ]]
+ CLANGXX_TO_USE=clang++-3.8
+ '[' '!' -f clang-3.5 ']'
+ CLANGXX_TO_USE=clang++-3.5
+ make -j4 CC=clang-3.5 CXX=clang++-3.5 clean
rm -f ../../src/hlslcc_lib/ir_expression_flattening.o ../../src/hlslcc_lib/opt_copy_propagation_elements.o ../../src/hlslcc_lib/lower_jumps.o ../../src/hlslcc_lib/PackUniformBuffers.o ../../src/hlslcc_lib/ir_constant_expression.o ../../src/hlslcc_lib/loop_analysis.o ../../src/hlslcc_lib/strtod.o ../../src/hlslcc_lib/loop_unroll.o ../../src/hlslcc_lib/ir_function_detect_recursion.o ../../src/hlslcc_lib/ir_rvalue_visitor.o ../../src/hlslcc_lib/ralloc.o ../../src/hlslcc_lib/ir_print_visitor.o ../../src/hlslcc_lib/glsl_types.o ../../src/hlslcc_lib/lower_instructions.o ../../src/hlslcc_lib/glsl_symbol_table.o ../../src/hlslcc_lib/lower_mat_op_to_vec.o ../../src/hlslcc_lib/lower_vec_index_to_swizzle.o ../../src/hlslcc_lib/lower_if_to_cond_assign.o ../../src/hlslcc_lib/hlslcc.o ../../src/hlslcc_lib/opt_noop_swizzle.o ../../src/hlslcc_lib/opt_constant_variable.o ../../src/hlslcc_lib/ast_to_hir.o ../../src/hlslcc_lib/glcpp-parse.o ../../src/hlslcc_lib/ir_function.o ../../src/hlslcc_lib/glsl_parser_extras.o ../../src/hlslcc_lib/lower_vec_index_to_cond_assign.o ../../src/hlslcc_lib/lower_output_reads.o ../../src/hlslcc_lib/hlsl_parser.o ../../src/hlslcc_lib/opt_dead_code.o ../../src/hlslcc_lib/hash_table.o ../../src/hlslcc_lib/glcpp-lex.o ../../src/hlslcc_lib/ir_hierarchical_visitor.o ../../src/hlslcc_lib/opt_redundant_jumps.o ../../src/hlslcc_lib/opt_tree_grafting.o ../../src/hlslcc_lib/opt_discard_simplification.o ../../src/hlslcc_lib/ir.o ../../src/hlslcc_lib/opt_copy_propagation.o ../../src/hlslcc_lib/ast_type.o ../../src/hlslcc_lib/lower_noise.o ../../src/hlslcc_lib/opt_constant_propagation.o ../../src/hlslcc_lib/opt_array_splitting.o ../../src/hlslcc_lib/ir_variable_refcount.o ../../src/hlslcc_lib/ShaderCompilerCommon.o ../../src/hlslcc_lib/symbol_table.o ../../src/hlslcc_lib/opt_function_inlining.o ../../src/hlslcc_lib/builtin_stubs.o ../../src/hlslcc_lib/ir_track_image_access.o ../../src/hlslcc_lib/opt_dead_code_local.o ../../src/hlslcc_lib/lower_variable_index_to_cond_assign.o ../../src/hlslcc_lib/hir_field_selection.o ../../src/hlslcc_lib/loop_controls.o ../../src/hlslcc_lib/lower_clip_distance.o ../../src/hlslcc_lib/hlsl_lexer.o ../../src/hlslcc_lib/opt_if_simplification.o ../../src/hlslcc_lib/pp.o ../../src/hlslcc_lib/OptValueNumbering.o ../../src/hlslcc_lib/opt_swizzle_swizzle.o ../../src/hlslcc_lib/ir_clone.o ../../src/hlslcc_lib/ast_function.o ../../src/hlslcc_lib/opt_algebraic.o ../../src/hlslcc_lib/ir_import_prototypes.o ../../src/hlslcc_lib/ast_expr.o ../../src/hlslcc_lib/opt_constant_folding.o ../../src/hlslcc_lib/opt_structure_splitting.o ../../src/hlslcc_lib/ir_unused_structs.o ../../src/hlslcc_lib/opt_dead_functions.o ../../src/hlslcc_lib/ir_hv_accept.o ../../src/hlslcc_lib/lower_vector.o ../../src/hlslcc_lib/ir_function_can_inline.o ../../src/hlslcc_lib/ir_validate.o ../../src/hlslcc_lib/IRDump.o ../../src/hlslcc_lib/lower_texture_projection.o ../../src/hlslcc_lib/lower_discard.o ../../src/hlslcc_lib/ir_basic_block.o ../../src/hlslcc_exe/main.o ../../lib/Linux/x86_64-unknown-linux-gnu/libhlslcc.a ../../bin/Linux/hlslcc_64
+ make -j4 CC=clang-3.5 CXX=clang++-3.5
clang++-3.5 -fPIC -Wno-switch -Wno-unused-value -I../../src/hlslcc_lib -fvisibility=hidden -DNDEBUG -g -O2 -nostdinc++ -I../../src/../../../Linux/LibCxx/include/c++/v1 -std=c++11 -o ../../src/hlslcc_lib/ir_expression_flattening.o -c ../../src/hlslcc_lib/ir_expression_flattening.cpp
clang++-3.5 -fPIC -Wno-switch -Wno-unused-value -I../../src/hlslcc_lib -fvisibility=hidden -DNDEBUG -g -O2 -nostdinc++ -I../../src/../../../Linux/LibCxx/include/c++/v1 -std=c++11 -o ../../src/hlslcc_lib/opt_copy_propagation_elements.o -c ../../src/hlslcc_lib/opt_copy_propagation_elements.cpp
make: clang++-3.5: Command not found
Makefile:43: recipe for target '../../src/hlslcc_lib/ir_expression_flattening.o' failed
make: *** [../../src/hlslcc_lib/ir_expression_flattening.o] Error 127
make: *** Waiting for unfinished jobs....
make: clang++-3.5: Command not found
Makefile:43: recipe for target '../../src/hlslcc_lib/opt_copy_propagation_elements.o' failed
make: *** [../../src/hlslcc_lib/opt_copy_propagation_elements.o] Error 127
```

so, I needed to compile manually by 

```
$ cd Engine/Source/ThirdParty/hlslcc/hlslcc/projects/Linux
$ make -j4 CC=clang-3.8 CXX=clang++-3.8 TARGET_ARCH=x86_64-unknown-linux-gnu
```

Maybe, I would change `HLSLCC.Build.cs` but I'm not familiar with c# build ecosystem, so I didn't do that.

```
$ make
  ...
  Total build time: 10287.91 seconds
```

- references

- examples