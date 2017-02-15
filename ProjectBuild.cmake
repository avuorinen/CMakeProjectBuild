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


set(PB_USE_ANDROID_MK FALSE)

set(PB_ANDROID_ABI "armeabi" "armeabi-v7a" "x86")

macro(BuildBegin)

	if(PB_RECURSION)
	
		set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
		set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
		set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
	
	elseif(ANDROID)

		add_custom_target(SetupProjects)
		add_custom_target(BuildProjects)

		set(PB_TARGET_GENERATOR "Unix Makefiles")
		
		add_custom_command(TARGET SetupProjects PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/jni/")
			
						
		add_custom_command(TARGET BuildProjects PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/libs")
		
		foreach(ABI ${PB_ANDROID_ABI})
		
			add_custom_command(TARGET SetupProjects PRE_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/build/${ABI}/")
				
			if(PB_DEBUG)
				set(PB_TARGET_GENERATOR ${CMAKE_GENERATOR})
				
				add_custom_command(TARGET SetupProjects PRE_BUILD
					COMMAND cmake -G "${PB_TARGET_GENERATOR}" "${PROJECT_SOURCE_DIR}/" -DPB_RECURSION=TRUE -DANDROID_ABI=${ABI}
					WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/build/${ABI}/")
				
			else()

				add_custom_command(TARGET SetupProjects PRE_BUILD
					COMMAND cmake -G "${PB_TARGET_GENERATOR}" "${PROJECT_SOURCE_DIR}/" -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DPB_RECURSION=TRUE -DANDROID_ABI=${ABI}
					WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/build/${ABI}/")			
				
			endif()
			

				
			add_custom_command(TARGET BuildProjects PRE_BUILD
				COMMAND cmake --build "."
				WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/build/${ABI}/")
				
			# Copy lib folder content to jni/libs/${ABI}/
			
			add_custom_command(TARGET BuildProjects PRE_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_directory "${PROJECT_BINARY_DIR}/build/${ABI}/lib" "${PROJECT_BINARY_DIR}/libs/${ABI}")
								
		endforeach()
				
		#add_dependencies(SetupProjects BuildProjects)
		#add_dependencies(ALL_BUILD BuildProjects)
		
	endif()

endmacro(BuildBegin)

macro(BuildEnd)



endmacro(BuildEnd)

macro(BuildLibrary name type sources)

	if(ANDROID AND NOT PB_RECURSION)

		set(PROJECT_BUILD_USE_ANDROID_MK FALSE)
	
		if(EXISTS "${PROJECT_SOURCE_DIR}/Android.mk")
		
			# Copy directory to jni directory.
			# Add NDK building target once -> Check if NDK build is enabled.
			# Set ${PB_LIB_PATH}
			
			set(PROJECT_BUILD_USE_ANDROID_MK TRUE)
						
		return()
		
		endif()
		
	endif()

	if((ANDROID AND PB_RECURSION) OR NOT ANDROID)
	
		add_library(${name} ${type} ${sources})
		target_link_libraries(${name} PUBLIC ${LIBS})
	
	endif()
	
	if(ANDROID AND PB_RECURSION)
	
		# Add Custom Build rules
		# ${ANDROID_ABI} # Use this as folder name.
		# list(APPEND CMAKE_CXX_FLAGS " --sysroot=${ANDROID_SYSROOT}")
		
	endif()

endmacro(BuildLibrary name type sources)


macro(BuildApplication name sources)

if(ANDROID)

	BuildLibrary(${name} SHARED ${sources})

else()

	add_executable(${name} ${sources})
	target_link_libraries(${name} PUBLIC ${LIBS})


endif()

endmacro(BuildApplication name sources)
