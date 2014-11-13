
set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Set debug library postfix" FORCE)


macro(ADD_LIBRARY_THRIFT name)

if(WITH_SHARED_LIB)
    add_library(${name} SHARED ${ARGN})
    #target_link_libraries(${name} ${SYSLIBS})
    set_target_properties(${name} PROPERTIES 
        OUTPUT_NAME ${name}
        VERSION ${thrift_VERSION} 
        SOVERSION ${thrift_VERSION} )
    #set_target_properties(${name} PROPERTIES PUBLIC_HEADER "${thriftcpp_HEADERS}")
    install(TARGETS ${name}
        RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
        LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
        ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
        PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
endif()

if(WITH_STATIC_LIB)
    add_library(${name}_static STATIC ${ARGN})
    #target_link_libraries(${name}_static ${SYSLIBS})
    set_target_properties(${name}_static PROPERTIES 
        OUTPUT_NAME ${name}${STATIC_POSTFIX}
        VERSION ${thrift_VERSION} 
        SOVERSION ${thrift_VERSION} )
    install(TARGETS ${name}_static
        RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
        LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
        ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
        PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
endif()

endmacro()

macro(TARGET_LINK_LIBRARIES_THRIFT name)

if(WITH_SHARED_LIB)
    target_link_libraries(${name} ${ARGN})
endif()

if(WITH_STATIC_LIB)
    target_link_libraries(${name}_static ${ARGN})
endif()

endmacro()