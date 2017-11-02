cmake_minimum_required(VERSION 2.8)


project(EXAMPLE)



include("../ProjectBuild.cmake" REQUIRED)



BuildBegin()



add_subdirectory(SDL2)


add_subdirectory(library)

add_subdirectory(src)

