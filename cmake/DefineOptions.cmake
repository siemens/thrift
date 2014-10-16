# Libraries to build
option(WITH_LIBCPP "Build the C++ library" ON)


# C++ library options
option(WITH_ZLIB "Build with ZLIB support" OFF)
option(WITH_LIBEVENT "Build with libevent support" OFF)
option(WITH_QT4 "Build with Qt4 support" OFF)
option(WITH_OPENSSL "Build with OpenSSL support" ON)

option(WITH_BOOSTTHREADS "Build with Boost thread support" OFF)
option(WITH_STDTHREADS "Build with C++ std::thread support" OFF)

option(WITH_SHARED_LIB "Build with a shared library" ON)
option(WITH_STATIC_LIB "Build with a static library" ON)

option(BUILD_TESTING "Build with unit tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)

#NOTE: C++ compiler options are defined in the compile CMakeLists.txt


# Visual Studio only options
if(MSVC)
option(WITH_MT "Build unsing MT instead of MT (MSVC only)" OFF)

# Replace MD with MT
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
    # For Debug build types, append a "d" to the library names.
    set(CMAKE_DEBUG_POSTFIX "mtd" CACHE STRING "Set debug library postfix" FORCE)
    set(CMAKE_RELEASE_POSTFIX "mt" CACHE STRING "Set release library postfix" FORCE)
else(WITH_MT)
    # For Debug build types, append a "d" to the library names.
    set(CMAKE_DEBUG_POSTFIX "mdd" CACHE STRING "Set debug library postfix" FORCE)
    set(CMAKE_RELEASE_POSTFIX "md" CACHE STRING "Set release library postfix" FORCE)
endif(WITH_MT)

endif(MSVC)