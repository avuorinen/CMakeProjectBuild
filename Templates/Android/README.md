# Android Template

## Project Setup

Copy *Ant_Files* or *Gradle_Files* directory content to your android project directory.
If you don't have android project you can use the *SDL_Project* as template or example.

* [Gradle](Gradle_Files/README.md)
* Ant **(Legacy)**  

## Android Build

### Dependencies

* Android SDK
* Android NDK
* **Gradle** or **Apache Ant**
* Java JRE
* Make
    * example: GnuWin32
* GCC Compiler (optional)
    * Helps with Unix Makefiles

### Env

* ANDROID_NDK
* Path
    * Android SDK/tools
    * Android SDK/platform-tools
    * Android NDK/build
    * Java/jre/bin
    * Apache Ant/bin
    * Make
    * GCC Compiler (optional)

### CMake & Building

* Unix Makefiles
* Use android.toolchain.cmake
* make -j
