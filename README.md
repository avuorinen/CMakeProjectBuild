# CMakeProjectBuild
Simple pipeline for building cross-platform CMake projects.

## Variables

| Variable                      | Description                                                |
| :-----------------------------|:-----------------------------------------------------------|
| SOURCES                       | Source files                                               |
| INCLUDES                      | Include Directories                                        |
| LIBS                          | Libraries, use CMake targets                               |
| DEFINES			              | Public Defines                                             |
| DEFINES_PRIVATE 		        | Private Defines                                            |
| ARGS				              | Arguments for BuildApplication. (Will be added for the BuildLibrary command.) |

### ARGS
| Command                       | Args                          | Description                |
| :-----------------------------|:------------------------------|:---------------------------|
| BuildApplication              | WIN32                         | WinMain Entry              |
|                               | MACOSX_BUNDLE                 | OS X Application Bundle    |
|                               | EXCLUDE_FROM_ALL              |                            |

## Commands

| Command                       | Description                                                |
| :-----------------------------|:-----------------------------------------------------------|
| BuildBegin()                  | Adds custom build targets                                  |
| BuildNDK()                    | Uses Android.mk file instead of CMake                      |
| BuildIgnore()                 | Skips CMake file                                           |
| BuildLibrary(NAME TYPE)       | Builds Library                                             |
| BuildApplication(NAME)        | Builds Application (Shared Library for Android)            |


### Custom Build Targets

* ProjectSetup
* ProjectBuild
* ProjectRun

## Features

* Visual Studio support
* CMake build targets
* Android
    * NDK-build support
    * Android Toolchain

### TODO

  * Examples
    * Example Project
  * CMake Options
    * Android Version
  * Passing CMake variables

### Android Build

#### Dependencies

* Android SDK
* Android NDK
* Apache Ant
* Java JRE
* Make
    * example: GnuWin32
* GCC Compiler (optional)
    * Helps with Unix Makefiles

#### Env

* ANDROID_NDK
* Path
    * Android SDK/tools
    * Android SDK/platform-tools
    * Android NDK/build
    * Java/jre/bin
    * Apache Ant/bin
    * Make
    * GCC Compiler (optional)

#### CMake & Building

* Unix Makefiles
* Use android.toolchain.cmake
* make -j

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

set(SOURCES Main.c)

# Libraries for linking.
set(LIBS Library)

# Modified add_executable.
BuildApplication(Example)

```

### Library CMakeLists.txt

``` CMake
project(LIBRARY C)
file(GLOB SOURCES ${APP_SOURCE_DIR}/*.c ${APP_SOURCE_DIR}/*.h)

# Modified add_library.
BuildLibrary(Library SHARED)
```
