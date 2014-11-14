# Visual Studio specific options
if(MSVC)
    #For visual studio the library naming is as following:
    # Dynamic libraries:
    #  - thfirt.dll  for release library
    #  - thriftd.dll for debug library
    #
    # Static libraries:
    #  - thriftmd.lib for /MD release build
    #  - thriftmt.lib for /MT release build
    #
    #  - thriftmdd.lib for /MD debug build
    #  - thriftmtd.lib for /MT debug build
    #
    # the same holds for other libraries like libthriftz etc.

    # For Debug build types, append a "d" to the library names.
    set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Set debug library postfix" FORCE)
    set(CMAKE_RELEASE_POSTFIX "" CACHE STRING "Set release library postfix" FORCE)

    
    # Build using /MT option instead of /MD if the WITH_MT options is set
    if(WITH_MT)
        set(CompilerFlags
                CMAKE_CXX_FLAGS
                CMAKE_CXX_FLAGS_DEBUG
                CMAKE_CXX_FLAGS_RELEASE
                CMAKE_C_FLAGS
                CMAKE_C_FLAGS_DEBUG
                CMAKE_C_FLAGS_RELEASE
                )
        foreach(CompilerFlag ${CompilerFlags})
          string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
        endforeach()
        set(STATIC_POSTFIX "mt" CACHE STRING "Set static library postfix" FORCE)
    else(WITH_MT)
        set(STATIC_POSTFIX "md" CACHE STRING "Set static library postfix" FORCE)
    endif(WITH_MT)
endif(MSVC)

# GCC Specific
if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  # TODO: -pedantic can not be used at the moment because of: https://issues.apache.org/jira/browse/THRIFT-2784
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O2 -Wall -Wextra -pedantic")
endif()
