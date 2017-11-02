project(APP CXX)

file(GLOB SOURCES ${APP_SOURCE_DIR}/*.cpp ${EXAMPLE_SOURCE_DIR}/SDL2/src/main/android/*.c)
set(INCLUDES ${EXAMPLE_SOURCE_DIR}/library ${EXAMPLE_SOURCE_DIR}/SDL2/include)

set(LIBS SDL2 SDL2main library)

if(ANDROID)
	set(LIBS library log android SDL2)
endif()

BuildApplication(main)

