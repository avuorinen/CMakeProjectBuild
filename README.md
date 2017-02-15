# CMakeProjectBuild
Simple pipeline for building cross-platform CMake projects.

## Features

* CMake build targets
* Android
  * NDK-build support
  * Android Toolchain

## Example

<pre>
Project Root
|-- CMakeLists.txt
|-- src
    |-- Main.c
|-- Library
    |-- CMakeLists.txt
    |-- include
        |-- Lib.h
    |-- src
        |-- Lib.c
</pre>

### Project Root CMakeLists.txt

``` CMake
cmake_minimum_required(VERSION 2.8)

project(EXAMPLE)

include("cmake/ProjectBuild.cmake" REQUIRED)

# Handles build pipeline, windows, android, etc.
BuildBegin()

add_subdirectory(Library)

# Libraries for linking.
set(LIBS Library)

# Modified add_executable.
BuildApplication(Example Main.c)

```

### Library CMakeLists.txt

``` CMake
project(LIBRARY C)
file(GLOB LIB_SRC ${APP_SOURCE_DIR}/*.c ${APP_SOURCE_DIR}/*.h)

# Modified add_library.
BuildLibrary(Library SHARED ${LIB_SRC})
```
