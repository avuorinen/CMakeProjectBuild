project(LIB CXX)

file(GLOB SOURCES ${LIB_SOURCE_DIR}/*.cpp ${LIB_SOURCE_DIR}/*.h)
BuildLibrary(library STATIC)
