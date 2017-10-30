# Config
set(PB_CONFIG_NO_DEFAULTS true)
set(PB_CONFIG_USE_BuildLibrary true)
set(PB_CONFIG_USE_BuildTargetBegin true)

include("${PB_PLATFORM_DIR}/PB_Default.cmake")

# Properties
if(ANDROID)
	set(PB-ANDROID TRUE CACHE BOOL "" )
else()
	set(PB-ANDROID FALSE CACHE BOOL "" )
endif()

set(PB_USE_ANDROID_MK FALSE)

set(PB-ANDROID_ABI "armeabi" "armeabi-v7a" "x86" CACHE STRING "Android ABI Targets")
set(PB-ANDROID_API "9" CACHE STRING "Android API LEVEL")

set(ANDROID-STL_VALUES
	"none;system;system_re;gabi++_static;gabi++_shared;stlport_static;stlport_shared;gnustl_static;gnustl_shared;c++_static;c++_shared;"
)

set(PB-ANDROID_STL "c++_static" CACHE STRING "Android STL")
set_property(CACHE PB-ANDROID_STL PROPERTY STRINGS ${ANDROID_STL_VALUES})

set(ANDROID-BUILD_SYSTEMS
	"ant debug install;gradlew installDebug;"
)
set(PB-ANDROID_BUILD_SYSTEM "gradlew installDebug" CACHE STRING "Android Build System")
set_property(CACHE PB-ANDROID_BUILD_SYSTEM PROPERTY STRINGS ${ANDROID_BUILD_SYSTEMS})

set(PB-ANDROID FALSE CACHE BOOL "Is Android Project" )
set(PB-ANDROID_TEMPLATE "${PROJECT_SOURCE_DIR}/android_template" CACHE PATH "Android Project Template")
set(PB-ANDROID_NDK TRUE CACHE BOOL "Call ndk-build when building" )

macro(BuildNative names)
	separate_arguments(names)
	BuildDummy("${names}")
	BuildNDK()
endmacro(BuildNative names)

# BuildApplication
macro(BuildApplication name)
	BuildLibrary(${name} SHARED ${SOURCES})
endmacro(BuildApplication name)

# BuildTargetEnd
macro(BuildTargetEnd name)

	foreach(LIB ${LIBS})
		if(EXISTS "${BUILD_DIR}/android/libs/${ANDROID_ABI}/lib${LIB}.so")
			target_link_libraries(${name} PUBLIC "${BUILD_DIR}/android/libs/${ANDROID_ABI}/lib${LIB}.so")
		endif()
	endforeach()

	BuildTargetEnd_Default(${name})
	
endmacro(BuildTargetEnd name)

# BuildNDK
macro(BuildNDK)

	if(EXISTS "${PROJECT_SOURCE_DIR}/Android.mk")
		if(NOT PB_RECURSION)

			message(STATUS "PB NDK: " ${PROJECT_SOURCE_DIR})

			if(NOT EXISTS "${BUILD_DIR}/jni/${PROJECT_SOURCE_DIR}")
				file(COPY ${PROJECT_SOURCE_DIR} DESTINATION ${BUILD_DIR}/android/jni)
			endif()

		endif()

		if(NOT PB_FORCE_PROJECT OR PB_RECURSION)
			return()
		endif()

	endif()

endmacro(BuildNDK)

macro(BuildProject)

	if(PB-ANDROID_NDK)
		add_custom_target(PBuildNDK)
	endif()

	if(EXISTS "${PB_ANDROID_TEMPLATE}/AndroidManifest.xml" AND NOT EXISTS "${BUILD_DIR}/android/AndroidManifest.xml")

		file(REMOVE_RECURSE "${BUILD_DIR}/android")
		get_filename_component(TEMPLATE_NAME ${PB_ANDROID_TEMPLATE} NAME)
		file(COPY ${PB_ANDROID_TEMPLATE} DESTINATION ${BUILD_DIR})
		file(RENAME "${BUILD_DIR}/${TEMPLATE_NAME}" "${BUILD_DIR}/android")

	endif()

	add_custom_command(TARGET PSetup PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "ProjectBuild: Initializing projects..."
		COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/android/jni/"
		COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/android/libs"
	)

	# Option for this.
	#add_custom_command(TARGET PSetup PRE_BUILD
	#	COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/obj")


	if(PB_ANDROID_NDK)
		add_custom_command(TARGET PBuildNDK PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "ProjectBuild: Starting NDK building..."
			COMMAND ndk-build
			WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/android")
	endif()

	foreach(ABI ${PB-ANDROID_ABI})

		add_custom_command(TARGET PSetup PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/obj/${ABI}/")

		if(PB_DEBUG)

			# Temp.
			# TODO 'Generic' Project generation

			set(PB_TARGET_GENERATOR ${CMAKE_GENERATOR})
			add_custom_command(TARGET PSetup PRE_BUILD
				COMMAND cmake -G "${PB-CONFIG_GENERATOR}" "${PROJECT_SOURCE_DIR}/" -DANDROID_STL=${PB-ANDROID_STL} -DANDROID_NATIVE_API_LEVEL=${PB-ANDROID_API} -DPB_RECURSION=TRUE -DANDROID_ABI=${ABI} -DOUTPUT_PATH=${PROJECT_BINARY_DIR}/libs/${ABI} -DCMAKE_BUILD_TYPE=Debug -DPB-CONFIG_RELEASE=${PB-CONFIG_RELEASE} -DPB-CONFIG_PLATFORM=${PB-CONFIG_PLATFORM} ${PB_FLAGS}
				WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")
		else()

			add_custom_command(TARGET PSetup PRE_BUILD
				COMMAND cmake -G "${PB-CONFIG_GENERATOR}" "${PROJECT_SOURCE_DIR}/" -DCMAKE_TOOLCHAIN_FILE=${PB-CONFIG_TOOLCHAIN} -DPB_RECURSION=TRUE -DANDROID_ABI=${ABI} -DCMAKE_BUILD_TYPE=Release -DPB-CONFIG_RELEASE=${PB-CONFIG_RELEASE} -DANDROID_STL=${PB-ANDROID_STL} -DANDROID_NATIVE_API_LEVEL=${PB-ANDROID_API} -DPB-CONFIG_PLATFORM=${PB-CONFIG_PLATFORM} ${PB_FLAGS}
				WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")

		endif()

		add_custom_command(TARGET PBuild PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "ProjectBuild: Updating projects..."
			COMMAND cmake "."
			WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")

		add_custom_command(TARGET PBuild PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "ProjectBuild: Starting building..."
			COMMAND cmake --build "."
			WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/obj/${ABI}/")

		add_custom_command(TARGET PBuild PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_directory "${PROJECT_BINARY_DIR}/obj/${ABI}/lib" "${PROJECT_BINARY_DIR}/android/libs/${ABI}")

	endforeach()

	# Option for this. (PB_Install)
	SEPARATE_ARGUMENTS(PB-ANDROID_BUILD_SYSTEM)
	add_custom_command(TARGET PRun POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "ProjectBuild: Starting project..."
		COMMAND ${PB-ANDROID_BUILD_SYSTEM}
		WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/android")

	# Support for default target.
	if(PB-ANDROID_NDK)
		add_dependencies(PBuildNDK PSetup)
		add_dependencies(PBuild PBuildNDK)
		set_property(TARGET PBuildNDK PROPERTY FOLDER ProjectBuild)
	else()
		add_dependencies(PBuild PSetup)
	endif()

endmacro(BuildProject)