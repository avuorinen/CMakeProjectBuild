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
# INCLUDE_DIRS
# SOURCES
# LIBS


set(PB_USE_ANDROID_MK FALSE)

set(PB_ANDROID_ABI "armeabi" "armeabi-v7a" "x86")

macro(BuildBegin)


	if(PB_RECURSION)
	
		# Back to "root"
		get_filename_component(PARENT_DIR ${PROJECT_BINARY_DIR} DIRECTORY)
		get_filename_component(BUILD_DIR ${PARENT_DIR} DIRECTORY)
		message(STATUS ${BUILD_DIR})
	
		set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
		set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
		set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
		
	
	elseif(ANDROID)
	
		set(BUILD_DIR ${PROJECT_BINARY_DIR})

	
		add_custom_target(SetupProjects)
		add_custom_target(BuildProjects)

		set(PB_TARGET_GENERATOR "Unix Makefiles")
		
		add_custom_command(TARGET SetupProjects PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/jni/")
		
		# Option for this.
		#add_custom_command(TARGET SetupProjects PRE_BUILD
		#	COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/obj")			
			
		add_custom_command(TARGET BuildProjects PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/libs")
			
		add_custom_command(TARGET BuildProjects PRE_BUILD
			COMMAND ndk-build
			WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
			
		foreach(ABI ${PB_ANDROID_ABI})
		
			add_custom_command(TARGET SetupProjects PRE_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/obj/${ABI}/")
				
			if(PB_DEBUG)
				set(PB_TARGET_GENERATOR ${CMAKE_GENERATOR})
				
				add_custom_command(TARGET SetupProjects PRE_BUILD
					COMMAND cmake -G "${PB_TARGET_GENERATOR}" "${PROJECT_SOURCE_DIR}/" -DPB_RECURSION=TRUE -DANDROID_ABI=${ABI} -DOUTPUT_PATH=${PROJECT_BINARY_DIR}/libs/${ABI}
					WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")
				
			else()

				add_custom_command(TARGET SetupProjects PRE_BUILD
					COMMAND cmake -G "${PB_TARGET_GENERATOR}" "${PROJECT_SOURCE_DIR}/" -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DPB_RECURSION=TRUE -DANDROID_ABI=${ABI}
					WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")			
				
			endif()
			
			add_custom_command(TARGET BuildProjects PRE_BUILD
				COMMAND cmake "."
				WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")
							
			add_custom_command(TARGET BuildProjects PRE_BUILD
				COMMAND cmake --build "."
				WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")
				
			# Copy lib folder content to jni/libs/${ABI}/
			
			add_custom_command(TARGET BuildProjects PRE_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_directory "${PROJECT_BINARY_DIR}/obj/${ABI}/lib" "${PROJECT_BINARY_DIR}/libs/${ABI}")
								
		endforeach()
		
		
		# Option for this. (PB_Install)
		#add_custom_command(TARGET BuildProjects POST_BUILD
		#	COMMAND ant debug install
		#	WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
				
				
		# Support for default target.
				
		#add_dependencies(SetupProjects BuildProjects)
		#add_dependencies(ALL_BUILD BuildProjects)
		
	endif()

endmacro(BuildBegin)

macro(BuildNDK)

	if(ANDROID)
	
		if(EXISTS "${PROJECT_SOURCE_DIR}/Android.mk")
			if(NOT PB_RECURSION)
			
				message(STATUS "NDK: " ${PROJECT_SOURCE_DIR})
				file(COPY ${PROJECT_SOURCE_DIR} DESTINATION ${BUILD_DIR}/jni)
							
			endif()
						
		return()
		
		endif()
	endif()
		

endmacro(BuildNDK)

macro(BuildLibrary name type)

	BuildNDK()

	if((ANDROID AND PB_RECURSION) OR NOT ANDROID)
	
		include_directories(${INCLUDE_DIRS})
	
		if(${type} STREQUAL SHARED)
			add_library(${name} SHARED ${SOURCES})
		else()
			add_library(${name} STATIC ${SOURCES})
		endif()

		foreach(LIB ${LIBS})
			if(EXISTS "${BUILD_DIR}/libs/${ANDROID_ABI}/lib${LIB}.so")
				target_link_libraries(${name} PUBLIC "${BUILD_DIR}/libs/${ANDROID_ABI}/lib${LIB}.so")
			endif()
		endforeach()
					
		target_link_libraries(${name} PUBLIC ${LIBS})
		 
		 
	endif()
	
endmacro(BuildLibrary name)


macro(BuildApplication name)

if(ANDROID)

	BuildLibrary(${name} SHARED ${SOURCES})

else()

	include_directories(${INCLUDE_DIRS})
	add_executable(${name} ${SOURCES})
	target_link_libraries(${name} PUBLIC ${LIBS})

endif()

endmacro(BuildApplication name)
