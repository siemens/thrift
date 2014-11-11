include(CMakeDependentOption)

# Additional components
option(BUILD_COMPILER "Build the thrift compiler" ON)
option(BUILD_TESTING "Build with unit tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)
option(BUILD_LIBRARIES "Build the thrfit libraries" ON)

# Libraries to build

# C++
find_package(Boost 1.53 QUIET)
CMAKE_DEPENDENT_OPTION(WITH_CPP "Build the C++ library" ON
                       "BUILD_LIBRARIES;Boost_FOUND" OFF)
find_package(ZLIB QUIET)
CMAKE_DEPENDENT_OPTION(WITH_ZLIB "Build with ZLIB support" ON
                       "ZLIB_FOUND" OFF)
find_package(Libevent QUIET)
CMAKE_DEPENDENT_OPTION(WITH_LIBEVENT "Build with libevent support" ON
                       "Libevent_FOUND" OFF)
find_package(Qt4 QUIET)
CMAKE_DEPENDENT_OPTION(WITH_QT4 "Build with Qt4 support" ON
                       "Qt4_FOUND" OFF)
find_package(OpenSSL QUIET)
CMAKE_DEPENDENT_OPTION(WITH_OPENSSL "Build with OpenSSL support" ON
                       "OpenSSL_FOUND" OFF)
option(WITH_BOOSTTHREADS "Build with Boost thread support" OFF)
option(WITH_STDTHREADS "Build with C++ std::thread support" OFF)

# C GLib
find_package(GTK2 QUIET)
CMAKE_DEPENDENT_OPTION(WITH_C_GLIB "Build the GLib C library" ON
                       "BUILD_LIBRARIES;GTK2_FOUND" OFF)
# Java
find_package(Java QUIET)
CMAKE_DEPENDENT_OPTION(WITH_JAVA "Build with Java library" ON
                       "BUILD_LIBRARIES;JAVA_FOUND" OFF)

# Common library options
option(WITH_SHARED_LIB "Build with a shared library" ON)
option(WITH_STATIC_LIB "Build with a static library" ON)

#NOTE: C++ compiler options are defined in the lib/cpp/CMakeLists.txt


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