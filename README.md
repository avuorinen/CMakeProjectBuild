# CMakeProjectBuild
Simple pipeline for building cross-platform CMake projects.

## Files
- ProjectBuild.cmake
- Toolchains
- Platforms

### Platforms
  [Android Builidng](Templates/Android/README.md)

## Variables
| Variable        | Description                  |
| :-------------- | :--------------------------- |
| SOURCES         | Source files                 |
| INCLUDES        | Include Directories          |
| LIBS            | Libraries, use CMake targets |
| DEFINES         | Public Defines               |
| DEFINES_PRIVATE | Private Defines              |
| ARGS            | Arguments for commands       |


### ARGS
| Command            | Args                 | Description              |
| :------------------|:---------------------|:-------------------------|
| BuildApplication   | WIN32                | WinMain Entry            |
|                    | MACOSX_BUNDLE        | OS X Application Bundle  |
|                    | EXCLUDE_FROM_ALL     |                          |
| BuildLibrary       | WIP                  | WIP                      |


## Commands

| Command                 | Description                                     |
| :---------------------- | :---------------------------------------------- |
| BuildBegin()            | Adds custom build targets                       |
| BuildNDK()              | Uses Android.mk file instead of CMake           |
| BuildIgnore()           | Skips CMake file                                |
| BuildLibrary(NAME TYPE) | Builds Library                                  |
| BuildApplication(NAME)  | Builds Application (Shared Library for Android) |

### Custom Build Targets

* PSetup
* PBuild
* PRun
* PBuildNDK (Android)

## Features

* Visual Studio support
* CMake build targets
* Android
    * NDK-build support
    * Android Toolchain

### TODO
  * CMake Options
    * Android Version

## Example

<pre>
Project Root
|-- CMakeLists.txt
|-- src
    |-- main.c
|-- Library
    |-- CMakeLists.txt
    |-- include
        |-- lib.h
    |-- src
        |-- lib.c
</pre>

### Project Root/CMakeLists.txt

``` CMake
cmake_minimum_required(VERSION 2.8)

project(EXAMPLE)

include("cmake/ProjectBuild.cmake" REQUIRED)

# Handles build pipeline, windows, android, etc.
BuildBegin()

add_subdirectory(Library)

set(SOURCES main.c)

# Libraries for linking.
set(LIBS Library)

# Modified add_executable.
BuildApplication(Example)
```


### Project Root/Library/CMakeLists.txt

``` CMake
project(LIBRARY C)
file(GLOB SOURCES ${APP_SOURCE_DIR}/*.c ${APP_SOURCE_DIR}/*.h)

# Modified add_library.
BuildLibrary(Library SHARED)
```
