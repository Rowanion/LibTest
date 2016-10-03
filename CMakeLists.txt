cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

project(LibTest)

#######################################################################
# cmake includes
# contains convenience functions
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
include( Functions )
include( GenerateExportHeader )

set( LIBRARY_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/lib )
set( INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/include )

#######################################################################
## global configs ##

setupCompiler()

# change default value for install target
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH
      "Install path prefix, prepend onto install directories."
      FORCE)
endif()

#######################################################################
## Libs and project settings

#######################################################################
## 3rdParty Libs

#######################################################################
## This project's sources

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib/src
	${CMAKE_BINARY_DIR}
)

# add directories containing sources (.c .cpp .h .hpp) in this way 
# to create a matching folder structure within MSVC
addFilesInSubdir( lib/src )

# here you should add all libraries this project links to.
# Qt-stuff is already included!
set(${PROJECT_NAME}_LINK_LIBS
)

IF(WIN32)
	set(BINARY_PROPERTIES WIN32)
ENDIF()

# compile the resource files

# create groups for our generated files and source files.
setupGroupFolders()

set( CMAKE_CXX_VISIBILITY_PRESET hidden )
set( CMAKE_VISIBILITY_INLINES_HIDDEN 1 )

#######################################################################
## create/setup the binary
add_library(${PROJECT_NAME} SHARED
	${${PROJECT_NAME}_SOURCE_FILES}
	${${PROJECT_NAME}_HEADER_FILES}
	${${PROJECT_NAME}_UIS_H}
    ${${PROJECT_NAME}_RESOURCES_CPP}
    ${${PROJECT_NAME}_WIN_RESOURCES}
    ${${PROJECT_NAME}_TS_FILES}
    ${${PROJECT_NAME}_QM_FILES}
)

# enable filegroups (for Visual Studio)
SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES ENABLE_EXPORTS TRUE)

# link against these libs
target_link_libraries(${PROJECT_NAME} 
    ${${PROJECT_NAME}_LINK_LIBS}
)
# -----------------------
string(TOLOWER ${PROJECT_NAME} LIB_EXPORT_BASE_NAME)
generate_export_header( ${PROJECT_NAME} 
	BASE_NAME ${LIB_EXPORT_BASE_NAME}
)
install( TARGETS ${PROJECT_NAME} DESTINATION ${LIBRARY_INSTALL_DIR} )
install( FILES
	lib/src/TestObject.h
	${PROJECT_BINARY_DIR}/${PROJECT_NAME}_export.h DESTINATION ${INCLUDE_INSTALL_DIR}
)
# ----------------------
###############################################################################
add_executable(TestMain
	main/src/main.cpp
)
SET_TARGET_PROPERTIES(TestMain PROPERTIES ENABLE_EXPORTS TRUE)
target_link_libraries(TestMain 
    ${PROJECT_NAME}
)
###############################################################################
add_executable(FirstTest
	Test/FirstTest/main.cpp
)
SET_TARGET_PROPERTIES(FirstTest PROPERTIES ENABLE_EXPORTS TRUE)
target_link_libraries(FirstTest
    ${PROJECT_NAME}
)
###############################################################################
## test
enable_testing()
add_test( NAME First_Test 
	COMMAND FirstTest
)

###############################################################################
## install scripts
#INSTALL(CODE "FILE(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/)")
#INSTALL(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/)

#INSTALL(FILES ${${PROJECT_NAME}_QM_FILES} DESTINATION
#	${CMAKE_INSTALL_PREFIX})

#if( WIN32 )
#	install( FILES
#        ${QT5_LOCATIONS}
#        DESTINATION ${CMAKE_INSTALL_PREFIX}
#        CONFIGURATIONS RELEASE
#	)

#	install( FILES
#		${QtPlatformPlugin_location}
#		DESTINATION ${CMAKE_INSTALL_PREFIX}/platforms
#		CONFIGURATIONS RELEASE
#	)

#endif()
