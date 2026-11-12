# lz4dord

A simple and janky FFI for [lz4/lib](https://github.com/lz4/lz4/tree/dev/lib) for Dlang.
I don't plan to maintain or develop it much.
The FFI was made based on version 1.11.1.

## Explanation of the crappy code

lz4dord is not being developed as a standalone project (I want to make one specific program (no guarantee it will ever see the light of day) and it needs lz4).
I decided to publish this code in case it helps someone (all existing lz4 ports and FFIs for D are more than 4 years old, and there are none for 1.10.0+). I wrote the FFI itself by hand; AI helped me with testing and building lz4.
lz4dord has a lot of kludges (a dependency on the STATIC API in the shared build, while at the same time there is no support for the PRIVATE API).
When linking shared against lz4 on Windows, the D program must link the CRT as shared, otherwise an error may occur because of different ABIs (possibly due to my own mistake, or LDC2 may not be able to build properly with static UCRT).
I only built it on Windows and haven't tested it on Linux (I entrusted the verification to Claude with its sandbox).
lz4dord was originally written for 1.11.0.

## Building LZ4:

### Installation:

```
git clone --branch v1.11.1 --depth 1 https://github.com/lz4/lz4.git libs/lz4
```
### Build:

I used a CMake script (tools/build_lz4.cmake) created by AI:
```cmake
# Build libs/lz4 for dub.
#
#   cmake -DKIND=shared -P tools/build_lz4.cmake   # lz4.dll / liblz4.so
#   cmake -DKIND=static -P tools/build_lz4.cmake   # lz4.lib / liblz4.a
#
# Output: .out/lz4/<KIND>/  (on Windows with the VS generator: .out/lz4/<KIND>/Release/)
cmake_minimum_required(VERSION 3.15)

if(NOT DEFINED KIND)
  set(KIND shared)
endif()

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(SRC_DIR   "${ROOT}/libs/lz4/build/cmake")
set(BUILD_DIR "${ROOT}/.out/lz4/${KIND}")

if(KIND STREQUAL "shared")
  # Part of the API (LZ4LIB_STATIC_API: LZ4_compress_fast_extState_fastReset, ...,
  # as well as LZ4_compress_destSize_extState, which has no export macro at all in lz4.h)
  # is not marked __declspec(dllexport), so it is missing from lz4.dll on Windows.
  # CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS generates a .def file with all global symbols.
  # On Linux/macOS the option is ignored (everything is visible there anyway).
  set(KIND_FLAGS
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_STATIC_LIBS=OFF
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON)
elseif(KIND STREQUAL "static")
  set(KIND_FLAGS
    -DBUILD_SHARED_LIBS=OFF
    -DBUILD_STATIC_LIBS=ON)
else()
  message(FATAL_ERROR "KIND must be 'shared' or 'static', got '${KIND}'")
endif()

set(EXTRA_ARGS "")
if(DEFINED CMAKE_GENERATOR)
  list(APPEND EXTRA_ARGS -G "${CMAKE_GENERATOR}")
endif()
if(DEFINED CMAKE_MAKE_PROGRAM)
  list(APPEND EXTRA_ARGS "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
endif()
if(DEFINED CMAKE_C_COMPILER)
  list(APPEND EXTRA_ARGS "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
endif()
if(DEFINED CMAKE_C_FLAGS)
  list(APPEND EXTRA_ARGS "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}")
endif()

execute_process(
  COMMAND "${CMAKE_COMMAND}" -S "${SRC_DIR}" -B "${BUILD_DIR}"
          -DCMAKE_BUILD_TYPE=Release
          -DLZ4_BUILD_CLI=OFF
          ${KIND_FLAGS}
          ${EXTRA_ARGS}
  RESULT_VARIABLE rc)

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "lz4 (${KIND}): configure failed (${rc})")
endif()

execute_process(
  COMMAND "${CMAKE_COMMAND}" --build "${BUILD_DIR}" --config Release
  RESULT_VARIABLE rc)
if(NOT rc EQUAL 0)
  message(FATAL_ERROR "lz4 (${KIND}): build failed (${rc})")
endif()
```

If possible, I would not recommend using it. This script was obtained from AI for a quick sanity check.

## Example dub script for LDC2

This is just my dub.json that I used during testing (I can't guarantee that it will work for you):

```json
{
    "name": "testlz4dord",
    "description": "Testing lz4dord",
    "authors": [
        "Orundite"
    ],
    "license": "MIT AND BSD-2-Clause",
    "targetType": "executable",
    "targetPath": ".out/build/default",
    "sourcePaths": [
        "src"
    ],
    "importPaths": [
        "src"
    ],
    "libs": [
        "lz4"
    ],
    "dflags-windows-ldc": ["-mscrtlib=msvcrt"],
    "configurations": [
        {
            "name": "debug-output",
            "targetPath": ".out/build/debug",
            "preBuildCommands": [
                "cmake -DKIND=shared -P tools/build_lz4.cmake"
            ],
            "lflags-posix": [
                "-L$PACKAGE_DIR/.out/lz4/shared",
                "-Wl,-rpath,$PACKAGE_DIR/.out/lz4/shared"
            ],
            "lflags-windows": [
                "/LIBPATH:$PACKAGE_DIR/.out/lz4/shared/Release",
                "/LIBPATH:$PACKAGE_DIR/.out/lz4/shared"
            ],
            "postBuildCommands-windows": [
                "cmake -E copy_if_different \"$PACKAGE_DIR/.out/lz4/shared/Release/lz4.dll\" \"$DUB_TARGET_PATH\""
            ]
        },
        {
            "name": "release-output",
            "targetPath": ".out/build/release",
            "preBuildCommands": [
                "cmake -DKIND=shared -P tools/build_lz4.cmake"
            ],
            "lflags-posix": [
                "-L$PACKAGE_DIR/.out/lz4/shared",
                "-Wl,-rpath,$PACKAGE_DIR/.out/lz4/shared"
            ],
            "lflags-windows": [
                "/LIBPATH:$PACKAGE_DIR/.out/lz4/shared/Release"
            ],
            "postBuildCommands-windows": [
                "cmake -E copy_if_different \"$PACKAGE_DIR/.out/lz4/shared/Release/lz4.dll\" \"$DUB_TARGET_PATH\""
            ]
        },
        {
            "name": "debug-output-static",
            "targetPath": ".out/build/debug-static",
            "preBuildCommands": [
                "cmake -DKIND=static -P tools/build_lz4.cmake"
            ],
            "lflags-posix": [
                "-L$PACKAGE_DIR/.out/lz4/static"
            ],
            "lflags-windows": [
                "/LIBPATH:$PACKAGE_DIR/.out/lz4/static/Release"
            ]
        },
        {
            "name": "release-output-static",
            "targetPath": ".out/build/release-static",
            "preBuildCommands": [
                "cmake -DKIND=static -P tools/build_lz4.cmake"
            ],
            "lflags-posix": [
                "-L$PACKAGE_DIR/.out/lz4/static"
            ],
            "lflags-windows": [
                "/LIBPATH:$PACKAGE_DIR/.out/lz4/static/Release"
            ]
        }
    ]
}
```
This dub.json assumes that lz4dord is located in `src`. It may be possible to include it without copying the files into your project (via dub or git), but I'm only just starting to get to grips with Dlang and DUB, and I don't know how to do that.


## License

## License

The D bindings are Copyright (c) 2026 Orundite and are available under the
MIT license. Portions derived from the `lib` directory of
[lz4](https://github.com/lz4/lz4) v1.11.1 (declarations and documentation
comments, Copyright (c) Yann Collet) remain under the BSD 2-Clause license;
its notice is retained in each source file. Only `lib` was used, so no
GPL-licensed parts of lz4 are included.