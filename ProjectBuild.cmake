# Copyright (c) 2017 Atte Vuorinen <attevuorinen@gmail.com>
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgement in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.


# Variables:
# INCLUDES
# SOURCES
# LIBS
# DEFINES
# DEFINES_PRIVATE
# ARGS

if(NOT PB_ROOT)
	set(PB_ROOT ${CMAKE_CURRENT_LIST_DIR})
endif()

include("${PB_ROOT}/Platforms/PB_Platforms.cmake")

##########
# Values #
##########

if(PB_RECURSION)
	set(PB_RECURSION TRUE CACHE BOOL "Sub Project" )
else()
	set(PB_MAIN TRUE CACHE BOOL "Main Project" )
endif()

##########
# Config #
##########


set(PB_FLAGS CACHE STRING "General flags")
set(PB_CXX_FLAGS CACHE STRING "C++ Compiler Flags")
set(PB_C_FLAGS CACHE STRING "C Compiler Flags")

set(PB-CONFIG_FORCE_PROJECT FALSE CACHE BOOL "Use root project ()" )

set(PB-CONFIG_RELEASE FALSE CACHE BOOL "Release")
set(PB-CONFIG_TOOLCHAIN "${CMAKE_TOOLCHAIN_FILE}" CACHE FILEPATH "SubProject toolchain" )
set(PB-CONFIG_GENERATOR "Unix Makefiles" CACHE STRING "SubProject generator")

##########
# Macros #
##########

# BuildIgnore
macro(BuildIgnore)
	return()
endmacro(BuildIgnore)

macro(BuildDummy dummies)

	foreach(dummy ${dummies})
		add_custom_target(${dummy})
		list(APPEND PB_DUMMY_LIBS ${dummy})
	endforeach()	
	
	list(REMOVE_DUPLICATES PB_DUMMY_LIBS)
	set(PB_DUMMY_LIBS ${PB_DUMMY_LIBS} CACHE INTERNAL "")
	
endmacro(BuildDummy dummies)

# BuildBegin
# Setups Build environment
# Only call this on ROOT CMakeLists.txt file.
macro(BuildBegin)

	# TODO Add Root check. (just in case)

		if(PB_RECURSION)

			# Back to "root"
			get_filename_component(PARENT_DIR ${PROJECT_BINARY_DIR} DIRECTORY)
			get_filename_component(BUILD_DIR ${PARENT_DIR} DIRECTORY)
			message(STATUS ${BUILD_DIR})

			set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
			set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
			set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

			# Strips Debug information from the release binaries.
			if(PB-CONFIG_RELEASE)
				set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")
				set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")
			endif()

			# Set Recursion flags
			set(CMAKE_C_FLAGS "${PB_C_FLAGS}")
			set(CMAKE_CXX_FLAGS "${PB_CXX_FLAGS}")

			set(CMAKE_C_FLAGS_RELEASE "${PB_C_FLAGS}")
			set(CMAKE_CXX_FLAGS_RELEASE "${PB_CXX_FLAGS}")

			set(CMAKE_C_FLAGS_DEBUG "${PB_C_FLAGS}")
			set(CMAKE_CXX_FLAGS_DEBUG "${PB_CXX_FLAGS}")

		elseif(PB_MAIN)

			set(BUILD_DIR ${PROJECT_BINARY_DIR})

			add_custom_target(PSetup)
			add_custom_target(PBuild)
			add_custom_target(PRun)

			if(PB_CXX_FLAGS)
				list(APPEND PB_FLAGS "-DPB_CXX_FLAGS=${PB_CXX_FLAGS}")
			endif()

			if(PB_C_FLAGS)
				list(APPEND PB_FLAGS "-DPB_C_FLAGS=${PB_C_FLAGS}")
			endif()
			
			BuildProject()

			add_dependencies(PRun PBuild)

			add_library(PBuildHook SHARED)
			message(STATUS "PB INFO: Don't bother about above warning about PBuildHook, that is intended dirty hack for Make dependencies.")
			set_target_properties(PBuildHook PROPERTIES LINKER_LANGUAGE CXX)
			add_dependencies(PBuildHook PBuild)

			set_property(TARGET PSetup PBuild PRun PBuildHook PROPERTY FOLDER ProjectBuild)

		endif()

endmacro(BuildBegin)