#######################################################################
## Generic setup
## Should be called as one of the first things in a project.
MACRO(setupCompiler)
  # enable virtual folders in VC++
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)

  IF(CMAKE_GENERATOR MATCHES "NMake.*")
    add_definitions( -DECLIPSE )    
  ENDIF()

  # enable nmakes multi-processor usage and adds general build flags
  if(CMAKE_BUILD_TOOL MATCHES "(msdev|devenv|nmake)")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP ")
  endif()

# compile little test prog and run it to estimate pointer size in current config
  try_run(RUN_RESULT_VAR COMPILE_RESULT_VAR
    ${CMAKE_BINARY_DIR}
    "${CMAKE_MODULE_PATH}/pointerSize.c"
    RUN_OUTPUT_VARIABLE POINTER_SIZE
  )

  if(WIN32)
    if(POINTER_SIZE MATCHES 8)
      SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY bin/x64)
    else()
      SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY bin/x86)
    endif()
endif()
ENDMACRO(setupCompiler)
#######################################################################
## creates the grouped folder structures within VS
## expects usage of these variables to work properly:
### ${${PROJECT_NAME}_UIS}
### ${${PROJECT_NAME}_RESOURCES}
### ${${PROJECT_NAME}_TS_FILES}
### ${${PROJECT_NAME}_WIN_RESOURCES}
### ${${PROJECT_NAME}_QM_FILES}
### ${${PROJECT_NAME}_MOC}
### ${${PROJECT_NAME}_UIS_H}
### ${${PROJECT_NAME}_RESOURCES_CPP}
MACRO(setupGroupFolders)
  SOURCE_GROUP(XML\\Qt_UIs FILES ${${PROJECT_NAME}_UIS})
  SOURCE_GROUP(XML\\Qt_Resources FILES ${${PROJECT_NAME}_RESOURCES})
  SOURCE_GROUP(XML\\Qt_Translations FILES ${${PROJECT_NAME}_TS_FILES})
  IF(WIN32)
    SOURCE_GROUP(XML\\Win_Resources FILES ${${PROJECT_NAME}_WIN_RESOURCES})
  ENDIF(WIN32)
  SOURCE_GROUP("Generated Files\\Qt_Translations" FILES ${${PROJECT_NAME}_QM_FILES})
  SOURCE_GROUP("Generated Files\\Qt_MOCs" FILES ${${PROJECT_NAME}_MOC})
  SOURCE_GROUP("Generated Files\\Qt_UIs" FILES ${${PROJECT_NAME}_UIS_H})
  SOURCE_GROUP("Generated Files\\Qt_Resources" FILES ${${PROJECT_NAME}_RESOURCES_CPP})
ENDMACRO(setupGroupFolders)
#######################################################################
function(setupQt directory)
  if(DEFINED ${directory})
    # TODO: implement this manually
  endif()
endfunction()
#######################################################################
function(setupQt directory)
  if(DEFINED ${directory})
    # TODO: implement this manually
  endif()
endfunction()

macro( setupQt5 )
  # STRING(REGEX REPLACE "\\" "\\\\" THE_DIR ${directory} )
  # if( ${directory} STREQUAL "" )
  #   set( THE_DIR "C:/Qt/Qt5.5.0/5.5/msvc2013" )
  # endif()
  # set( QT5_ROOT_DIR ${THE_DIR} CACHE PATH "The root path for Qt5 in which one can find directories like bin, lib, include, etc" )
  # list( APPEND CMAKE_PREFIX_PATH ${QT5_ROOT_DIR} )
  # Tell CMake to run moc when necessary:
  set( CMAKE_AUTOMOC ON )
  # As moc files are generated in the binary dir, tell CMake
  # to always look for includes there:
  set( CMAKE_INCLUDE_CURRENT_DIR ON )
endmacro()

macro( useQt5Module moduleName )
  find_package(Qt5${moduleName} REQUIRED)
  include_directories( ${Qt5${moduleName}_INCLUDE_DIRS} )
  add_definitions( ${Qt5${moduleName}_DEFINITIONS} )
  mark_as_advanced( Qt5${moduleName}_DIR )
  get_target_property( Qt${moduleName}_location Qt5::${moduleName} LOCATION )
  list( APPEND QT5_LINK_LIBS ${Qt5${moduleName}_LIBRARIES} )
  list( APPEND QT5_LOCATIONS ${Qt${moduleName}_location} )
endmacro()

#######################################################################
#
# export file: copy it to the build tree on every build invocation and add rule for installation
#
function    (cm_export_file FILE DEST)
  if    (NOT TARGET export-files)
    add_custom_target(export-files ALL COMMENT "Exporting files into build tree")
  endif (NOT TARGET export-files)
  get_filename_component(FILENAME "${FILE}" NAME)
  add_custom_command(TARGET export-files COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/${FILE}" "${CMAKE_CURRENT_BINARY_DIR}/${DEST}/${FILENAME}")
  install(FILES "${FILE}" DESTINATION "${DEST}")
endfunction (cm_export_file)
#######################################################################
## parses each file in the argument list for need of moc-ification.
## files that need mocing are added to the result list.
macro(detectMocs _resultList)
  if(WIN32)
    SET(SCRIPT_EXT ".exe")
  endif()

  foreach(FILE ${ARGN})
    get_filename_component(ABS_FILE ${FILE} ABSOLUTE)
    runScript(NEEDS_MOC ${CMAKE_MODULE_PATH}/mocRequired${SCRIPT_EXT} ${ABS_FILE})
    if(NEEDS_MOC STREQUAL "1")
      list(APPEND ${_resultList} ${FILE})
    endif()
  endforeach()
endmacro()

#######################################################################
## convenience script exec function
### note: the ${ARGN} is an automatic list, 
### containing all argumets not covered in the declaration
MACRO(runScript result fullScriptPath )
    execute_process(COMMAND ${fullScriptPath} ${ARGN}
    RESULT_VARIABLE EXEC_RESULT   # contains the termination code, ie. 0
    OUTPUT_VARIABLE EXEC_OUTPUT   # contains the script output
  )

  # check if we could successfully run our script
  if(EXEC_RESULT STREQUAL "")
    MESSAGE("Error: The script ${fullScriptPath} was not found!")
  elseif(NOT EXEC_RESULT STREQUAL "0")
    MESSAGE("Error: The script ${fullScriptPath} terminated with an error \"${EXEC_RESULT}\":")
    MESSAGE(STATUS "   output: ${EXEC_OUTPUT}")
  else()
    SET(${result} "${EXEC_OUTPUT}")
  endif()
ENDMACRO()

#######################################################################
## add all files in the given dir to the project (.h .hpp .c .cpp) and 
## create a folder in the same way
#######################################################################
MACRO(addFilesInSubdir _subdir)
  # source files
  file(GLOB ${PROJECT_NAME}_FILES_TEMP_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}/*.cpp
  )

  file(GLOB ${PROJECT_NAME}_FILES_TEMP_HEADER
    ${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}/*.h 
    ${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}/*.hpp 
  )

  # append all found files to the global var
  FOREACH(TEMP_FILE ${${PROJECT_NAME}_FILES_TEMP_SRC})
    list(APPEND ${PROJECT_NAME}_SOURCE_FILES ${TEMP_FILE})
  ENDFOREACH()
  FOREACH(TEMP_FILE ${${PROJECT_NAME}_FILES_TEMP_HEADER})
    list(APPEND ${PROJECT_NAME}_HEADER_FILES ${TEMP_FILE})
  ENDFOREACH()

  # use some regex magic to satisfy MSVC's needs
  STRING(REGEX REPLACE "/" "\\\\" MS_SUBDIR ${_subdir} )
  source_group("${MS_SUBDIR}" FILES ${${PROJECT_NAME}_FILES_TEMP_SRC})
  source_group("${MS_SUBDIR}" FILES ${${PROJECT_NAME}_FILES_TEMP_HEADER})
  SET( ${PROJECT_NAME}_FILES_TEMP_SRC "")
  SET( ${PROJECT_NAME}_FILES_TEMP_HEADER "")
ENDMACRO()

#######################################################################
## add all ui files in the given dir to the project
#######################################################################
macro(addUiInSubdir _subdir)
  # source files
  file(GLOB ${PROJECT_NAME}_FILES_TEMP_UIS
    ${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}/*.ui
  )

  # append all found files to the global var
  foreach(TEMP_FILE ${${PROJECT_NAME}_FILES_TEMP_UIS})
    list(APPEND ${PROJECT_NAME}_UIS ${TEMP_FILE})
  endforeach()

  # use some regex magic to satisfy MSVC's needs
  STRING(REGEX REPLACE "/" "\\\\" MS_SUBDIR ${_subdir} )
  source_group("${MS_SUBDIR}" FILES ${${PROJECT_NAME}_FILES_TEMP_SRC})
  source_group("${MS_SUBDIR}" FILES ${${PROJECT_NAME}_FILES_TEMP_HEADER})
  set( ${PROJECT_NAME}_FILES_TEMP_SRC "")
  set( ${PROJECT_NAME}_FILES_TEMP_HEADER "")
endmacro()

# #######################################################################
macro(QT4_ADD_TRANSLATION _qm_files)

  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated/QM")
  foreach (_current_FILE ${ARGN})
    get_filename_component(_abs_FILE ${_current_FILE} ABSOLUTE)
    get_filename_component(qm ${_abs_FILE} NAME_WE)
    get_source_file_property(output_location ${_abs_FILE} OUTPUT_LOCATION)
    if(output_location)
      file(MAKE_DIRECTORY "${output_location}")
      set(qm "${output_location}/${qm}.qm")
    else()
      set(qm "${CMAKE_CURRENT_BINARY_DIR}/generated/QM/${qm}.qm")
    endif()

    add_custom_command(OUTPUT ${qm}
       COMMAND ${QT_LRELEASE_EXECUTABLE}
       ARGS ${_abs_FILE} -qm ${qm}
       DEPENDS ${_abs_FILE} VERBATIM
    )
    set(${_qm_files} ${${_qm_files}} ${qm})
  endforeach ()
  include_directories(${CMAKE_CURRENT_BINARY_DIR}/generated/QM)
endmacro()
#######################################################################
# macro used to create the names of output files preserving relative dirs
macro (QT4_MAKE_OUTPUT_FILE infile prefix ext outfile )
  string(LENGTH ${CMAKE_CURRENT_BINARY_DIR} _binlength)
  string(LENGTH ${infile} _infileLength)
  set(_checkinfile ${CMAKE_CURRENT_SOURCE_DIR})
  if(_infileLength GREATER _binlength)
    string(SUBSTRING "${infile}" 0 ${_binlength} _checkinfile)
    if(_checkinfile STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
      file(RELATIVE_PATH rel ${CMAKE_CURRENT_BINARY_DIR} ${infile})
    else()
      file(RELATIVE_PATH rel ${CMAKE_CURRENT_SOURCE_DIR} ${infile})
    endif()
  else()
    file(RELATIVE_PATH rel ${CMAKE_CURRENT_SOURCE_DIR} ${infile})
  endif()
  if(WIN32 AND rel MATCHES "^[a-zA-Z]:") # absolute path
    string(REGEX REPLACE "^([a-zA-Z]):(.*)$" "\\1_\\2" rel "${rel}")
  endif()
  set(_outfile "${CMAKE_CURRENT_BINARY_DIR}/generated/MOC/${rel}")
  string(REPLACE ".." "__" _outfile ${_outfile})
  get_filename_component(outpath ${_outfile} PATH)
  get_filename_component(_outfile ${_outfile} NAME_WE)
  file(MAKE_DIRECTORY ${outpath})
  set(${outfile} ${outpath}/${prefix}${_outfile}.${ext})
endmacro ()
#######################################################################
#######################################################################
function(rename_option new old text def)
  if(DEFINED ${old})
    option(${new} ${text} ${${old}})
    unset(${old} CACHE)
  else()
    option(${new} ${text} ${def})
  endif()
endfunction()
#######################################################################
# convenience macros
#######################################################################
macro(add_headers srcvar)
  set(includedirs ${ARGN})
  foreach(src ${${srcvar}})
    get_filename_component(name ${src} NAME_WE)
    foreach(incdir ${includedirs})
      get_filename_component(hdr ${incdir}/${name}.h ABSOLUTE)
      if(EXISTS ${hdr})
        set(headers ${headers} ${hdr})
      endif()
    endforeach()
  endforeach()
  set(${srcvar} ${${srcvar}} ${headers})
endmacro()

#######################################################################
# macros for the various copy protection targets
#######################################################################
macro(release_executable target)
  if(COBRA_CUSTOMER_RELEASE_BUILD)
    set(link_libs ${ARGN})

    get_property(sources TARGET ${target} PROPERTY SOURCES)
    get_property(win32 TARGET ${target} PROPERTY WIN32_EXECUTABLE)
    if(win32)
      set(win32 WIN32)
    endif(win32)

    get_property(defines TARGET ${target} PROPERTY COMPILE_DEFINITIONS)
    get_property(defines_debug TARGET ${target} PROPERTY COMPILE_DEFINITIONS_DEBUG)
    get_property(defines_release TARGET ${target} PROPERTY COMPILE_DEFINITIONS_RELEASE)

    # filter out NO_RELEASE define
    if(defines)
      list(REMOVE_ITEM defines NO_RELEASE)
      list(REMOVE_ITEM defines NOLICENSE)
    endif(defines)

    if(defines_debug)
      list(REMOVE_ITEM defines_debug NO_RELEASE)
      list(REMOVE_ITEM defines_debug NOLICENSE)
    endif(defines_debug)

    if(defines_release)
      list(REMOVE_ITEM defines_release NO_RELEASE)
      list(REMOVE_ITEM defines_release NOLICENSE)
    endif(defines_release)

    get_property(linker_flags TARGET ${target} PROPERTY LINK_FLAGS)
    get_property(linker_flags_debug TARGET ${target} PROPERTY LINK_FLAGS_DEBUG)
    get_property(linker_flags_release TARGET ${target} PROPERTY LINK_FLAGS_RELEASE)

    set_property(TARGET ${target} PROPERTY EXCLUDE_FROM_ALL)


    set(RELBUILDS Softlock TestVersion Sentinel Wibu WibuSoftlock)
    

    if(${target} STREQUAL lush OR
       ${target} STREQUAL lush_wibu_remote OR
       ${target} MATCHES .*Manual OR
       ${target} MATCHES .*ServerClient ) 
      set(testversionlib testversion_console)
    else()
      set(testversionlib testversion)
    endif() 

    foreach(relbuild ${RELBUILDS})
      add_executable(${target}${relbuild} ${win32} ${sources})
      if(${relbuild} STREQUAL TestVersion)
        target_link_libraries(${target}${relbuild} ${link_libs} ${testversionlib}_on)
      else()
        target_link_libraries(${target}${relbuild} ${link_libs} ${testversionlib}_off)
      endif()
      set_target_properties(${target}${relbuild} PROPERTIES
       COMPILE_DEFINITIONS "${defines}"
       COMPILE_DEFINITIONS_DEBUG "${defines_debug}"
       COMPILE_DEFINITIONS_RELEASE "${defines_release}"
       LINK_FLAGS "${linker_flags}"
       LINK_FLAGS_DEBUG "${linker_flags_debug}"
       LINK_FLAGS_RELEASE "${linker_flags_release}"
       FOLDER "${relbuild}"
      )

      if (${target} MATCHES LucidDrive.* OR ${target} MATCHES LucidRoadEditor.*)
        install(TARGETS ${target}${relbuild}
          DESTINATION ${DRIVE_ROOT} 
          CONFIGURATIONS Release
          )
      else()
        install(TARGETS ${target}${relbuild}
          DESTINATION ${LUCID_ROOT}
          CONFIGURATIONS Release
          )
      endif()
    endforeach(relbuild)



    target_link_libraries( ${target}Sentinel spromeps )

    set_property(TARGET ${target}Softlock APPEND PROPERTY
      COMPILE_DEFINITIONS SOFTLOCK_VERSION 
    )
    
    set_property(TARGET ${target}TestVersion APPEND PROPERTY
      COMPILE_DEFINITIONS TEST_VERSION
    )

    set_property(TARGET ${target}Sentinel APPEND PROPERTY
      COMPILE_DEFINITIONS DONGLE_LICENSE
    )
    #set_property(TARGET ${target}Wibu APPEND PROPERTY
    #  COMPILE_DEFINITIONS DONGLE_LICENSE WLICENSE
    #)

	   set_property(TARGET ${target}Wibu APPEND PROPERTY
         COMPILE_DEFINITIONS DONGLE_LICENSE WLICENSE
         )

    set_property(TARGET ${target}WibuSoftlock APPEND PROPERTY
      COMPILE_DEFINITIONS DONGLE_LICENSE WLICENSE_WITH_SOFTLOCK
    )

    if(${target} STREQUAL LucidLite)
      set_property(TARGET ${target}Wibu APPEND PROPERTY
        COMPILE_DEFINITIONS
      )
      set_property(TARGET ${target}WibuSoftlock APPEND PROPERTY
        COMPILE_DEFINITIONS
      )
    endif(${target} STREQUAL LucidLite)

    if(${target} STREQUAL LucidDrive OR
       ${target} STREQUAL LucidRoadEditor)
#       ${target} STREQUAL LucidStudio OR
#       ${target} STREQUAL lush )

      set_property(TARGET ${target}WibuSoftlock APPEND PROPERTY
        COMPILE_DEFINITIONS
      )

    endif(${target} STREQUAL LucidDrive OR
       ${target} STREQUAL LucidRoadEditor)
# OR
#       ${target} STREQUAL LucidStudio OR
#       ${target} STREQUAL lush )


    if(${target} STREQUAL lush ) # extra lush_wibu_remote

      add_executable(${target}_wibu_remote ${win32} ${sources})
      target_link_libraries(${target}_wibu_remote ${link_libs} ${testversionlib}_off)
      set_target_properties(${target}_wibu_remote PROPERTIES
       COMPILE_DEFINITIONS "${defines}"
       COMPILE_DEFINITIONS_DEBUG "${defines_debug}"
       COMPILE_DEFINITIONS_RELEASE "${defines_release}"
       LINK_FLAGS "${linker_flags}"
       LINK_FLAGS_DEBUG "${linker_flags_debug}"
       LINK_FLAGS_RELEASE "${linker_flags_release}"
       FOLDER "WibuRemote"
      )
      set_property(TARGET ${target}_wibu_remote APPEND PROPERTY
        COMPILE_DEFINITIONS DONGLE_LICENSE WLICENSE REMOTELUSH
      )
    endif(${target} STREQUAL lush )


    foreach(config ${CMAKE_CONFIGURATION_TYPES})
      if(${target} MATCHES LucidDrive.* OR ${target} MATCHES LucidRoadEditor.*)
        set(INI_INSTALL_DIR ${DRIVE_ROOT})
      else(${target} MATCHES LucidDrive.* OR ${target} MATCHES LucidRoadEditor.*)
        set(INI_INSTALL_DIR ${LUCID_ROOT})
      endif(${target} MATCHES LucidDrive.* OR ${target} MATCHES LucidRoadEditor.*)

      foreach(relbuild ${RELBUILDS})
        #message(STATUS "creating ${config}/${target}${relbuild}_cmake_installdir.ini")
        configure_file(
          ${CoBra_SOURCE_DIR}/Lucid.ini.in
          ${config}/${target}${relbuild}_cmake_installdir.ini
          )
      endforeach(relbuild ${RELBUILDS})
    endforeach(config ${CMAKE_CONFIGURATION_TYPES})

#    include(${target}Install.txt)

  endif(COBRA_CUSTOMER_RELEASE_BUILD)
endmacro(release_executable target)
#######################################################################
# configuration convenience
#######################################################################
macro(change_flag vars configs regex val)
#  message(STATUS "cf: ${vars} ${configs}")

  foreach(config ${configs})
    foreach(var ${vars})
      if (config)
        set(varc ${var}_${config})
      else()
        set(varc ${var})
      endif ()
#      message(STATUS "before: ${varc}=${${varc}}")
      if(${varc} MATCHES ${regex})
        string(REGEX REPLACE ${regex} ${val} ${varc} "${${varc}}")
      elseif(NOT ${varc} MATCHES ${val})
        set(${varc} "${${varc}} ${val}")
      endif()
#      message(STATUS "after: ${varc}=${${varc}}")
    endforeach()
  endforeach()
endmacro()
#######################################################################
# changes compiler flags, searching for flag_regex and replace by
# flag_val if found, else appends flag_val to flags
#######################################################################
macro(change_compiler_flag compiler configs flag_regex flag_val)
  if (NOT ${compiler}) 
    return()
  endif()

  if ("${configs}" STREQUAL ALL)
    set(flag_configs NO DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
  else()
    set(flag_configs ${configs})
  endif()

  change_flag("CMAKE_CXX_FLAGS;CMAKE_C_FLAGS" "${flag_configs}" ${flag_regex} ${flag_val} )
endmacro()
#######################################################################
# changes linker flags, searching for flag_regex and replace by
# flag_val if found, else appends flag_val to flags
macro(change_linker_flag linker configs flag_regex flag_val)
  if (NOT ${linker})
    return()
  endif()

  if ("${configs}" STREQUAL ALL)
    set(flag_configs NO DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
  else()
    set(flag_configs ${configs})
  endif()

  change_flag("CMAKE_EXE_LINKER_FLAGS" "${flag_configs}" ${flag_regex} ${flag_val} )
endmacro()


