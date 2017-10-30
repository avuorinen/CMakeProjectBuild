# Config Variables
# PB_CONFIG_NO_DEFAULTS
# PB_CONFIG_USE_${NAME}

# User Variables
# INCLUDES
# SOURCES
# LIBS
# DEFINES
# DEFINES_PRIVATE

# Project Variables
# PB_BUILD_DIR (TODO: Build dir or Build/Android, etc.)

## Native
macro(BuildNative_Default names)

endmacro(BuildNative_Default names)

## Begin
macro(BuildTargetBegin_Default name)
	include_directories(${INCLUDES})
	add_definitions(${DEFINES})
endmacro(BuildTargetBegin_Default name)

## End
macro(BuildTargetEnd_Default name)

	if(LIBS)
		foreach(dummy ${PB_DUMMY_LIBS})	
			list(FILTER LIBS EXCLUDE REGEX "${dummy}") 
		endforeach()
	endif()
	
	target_link_libraries(${name} PUBLIC ${LIBS})
	target_compile_definitions(${name} PRIVATE ${DEFINES_PRIVATE})
endmacro(BuildTargetEnd_Default name)

## Libary
macro(BuildLibrary_Default name type)

	BuildTargetBegin(${name})

	if(${type} STREQUAL SHARED)
		add_library(${name} SHARED ${SOURCES})
	else()
		add_library(${name} STATIC ${SOURCES})
	endif()

	BuildTargetEnd(${name})

endmacro(BuildLibrary_Default name)

## Application
macro(BuildApplication_Default name)
	BuildTargetBegin(${name})
	add_executable(${name} ${ARGS} ${SOURCES})
	BuildTargetEnd(${name})
endmacro(BuildApplication_Default name)


macro(BuildProject_Default)

endmacro(BuildProject_Default)

# Defaults Wrappers #

# Native
if(NOT PB_CONFIG_NO_DEFAULTS OR PB_CONFIG_USE_BuildNative)
	macro(BuildNative names)
		BuildNative_Default(${names})
	endmacro(BuildNative names)
	
	macro(BuildSkipNative)
	endmacro()
else()
	macro(BuildSkipNative)
		return()
	endmacro()
endif()

# BuildLibrary
if(NOT PB_CONFIG_NO_DEFAULTS OR PB_CONFIG_USE_BuildLibrary)
	macro(BuildLibrary name type)
		BuildLibrary_Default(${name} ${type})
	endmacro(BuildLibrary name)
endif()
 
# BuildApplication
if(NOT PB_CONFIG_NO_DEFAULTS OR PB_CONFIG_USE_BuildApplication)
	macro(BuildApplication name)
		BuildApplication_Default(${name})
	endmacro(BuildApplication name)
endif()

# BuildTargetBegin
if(NOT PB_CONFIG_NO_DEFAULTS OR PB_CONFIG_USE_BuildTargetBegin)
	macro(BuildTargetBegin name)
		BuildTargetBegin_Default(${name})
	endmacro(BuildTargetBegin name)
endif()

# BuildTargetEnd
if(NOT PB_CONFIG_NO_DEFAULTS OR PB_CONFIG_USE_BuildTargetEnd)
	macro(BuildTargetEnd name)
		BuildTargetEnd_Default(${name})
	endmacro(BuildTargetEnd name)
endif()

# BuildProject
if(NOT PB_CONFIG_NO_DEFAULTS OR PB_CONFIG_USE_BuildProject)
	macro(BuildProject)
		BuildProject_Default()
	endmacro(BuildProject)
endif()

