#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#


cmake_minimum_required(VERSION 2.8)

project(thriftcpp)

# CMake specific files like templates and find modules are in the cmake subdirectory of the source dir
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Some default settings
include(DefineCMakeDefaults)

# Build time options are defined here
include(DefineOptions)

# Read the version information from the Autoconf file
file (STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/../../configure.ac" CONFIGURE_AC REGEX "AC_INIT\\(.*\\)" )

# The following variable is used in the version.h.in file
string(REGEX REPLACE "AC_INIT\\(\\[.*\\], \\[([0-9]+\\.[0-9]+\\.[0-9]+(-dev)?)\\]\\)" "\\1" PACKAGE_VERSION ${CONFIGURE_AC})
set(PACKAGE_NAME "thrift")
message(STATUS "Thrift package version: ${PACKAGE_VERSION}")


# These are internal to CMake
string(REGEX REPLACE "([0-9]+\\.[0-9]+\\.[0-9]+)(-dev)?" "\\1" thrift_VERSION ${PACKAGE_VERSION})
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" thrift_VERSION_MAJOR ${thrift_VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9])+\\.[0-9]+" "\\1" thrift_VERSION_MINOR ${thrift_VERSION})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" thrift_VERSION_PATCH ${thrift_VERSION})
message(STATUS "Thrift version: ${thrift_VERSION} (${thrift_VERSION_MAJOR}.${thrift_VERSION_MINOR}.${thrift_VERSION_PATCH})")

# Find required packages
find_package(Boost 1.53.0 REQUIRED)
include_directories("${Boost_INCLUDE_DIR}")

# Create the thrift C++ library
set( thriftcpp_SOURCES
   src/thrift/Thrift.cpp
   src/thrift/TApplicationException.cpp
   src/thrift/VirtualProfiling.cpp
   src/thrift/concurrency/ThreadManager.cpp
   src/thrift/concurrency/TimerManager.cpp
   src/thrift/concurrency/Util.cpp
   src/thrift/protocol/TDebugProtocol.cpp
   src/thrift/protocol/TDenseProtocol.cpp
   src/thrift/protocol/TJSONProtocol.cpp
   src/thrift/protocol/TBase64Utils.cpp
   src/thrift/protocol/TMultiplexedProtocol.cpp
   src/thrift/transport/TTransportException.cpp
   src/thrift/transport/TFDTransport.cpp
   src/thrift/transport/TSimpleFileTransport.cpp
   src/thrift/transport/THttpTransport.cpp
   src/thrift/transport/THttpClient.cpp
   src/thrift/transport/THttpServer.cpp
   src/thrift/transport/TSocket.cpp
   src/thrift/transport/TSocketPool.cpp
   src/thrift/transport/TServerSocket.cpp
   src/thrift/transport/TTransportUtils.cpp
   src/thrift/transport/TBufferTransports.cpp
   src/thrift/server/TServer.cpp
   src/thrift/server/TSimpleServer.cpp
   src/thrift/server/TThreadPoolServer.cpp
   src/thrift/server/TThreadedServer.cpp
   src/thrift/async/TAsyncChannel.cpp
   src/thrift/processor/PeekProcessor.cpp
)

# Install the headers
install(DIRECTORY "src/thrift" DESTINATION "include"
    FILES_MATCHING PATTERN "*.h")

# This files don't work on Windows CE as there is no pipe support
if (NOT WINCE)
    list(APPEND thriftcpp_SOURCES
       src/thrift/transport/TPipe.cpp
       src/thrift/transport/TPipeServer.cpp
       src/thrift/transport/TFileTransport.cpp
    )
endif()


if (WIN32)
    list(APPEND thriftcpp_SOURCES
        src/thrift/windows/TWinsockSingleton.cpp
        src/thrift/windows/SocketPair.cpp
        src/thrift/windows/GetTimeOfDay.cpp
        src/thrift/windows/WinFcntl.cpp
    )
    if(NOT WINCE)
        # This file uses pipes so it currently won't work on Windows CE
        list(APPEND thriftcpp_SOURCES
            src/thrift/windows/OverlappedSubmissionThread.cpp
        )
    endif()
endif()

# If OpenSSL is not found just ignore the OpenSSL stuff
find_package(OpenSSL)
if(OPENSSL_FOUND AND WITH_OPENSSL)
    list( APPEND thriftcpp_SOURCES
       src/thrift/transport/TSSLSocket.cpp
       src/thrift/transport/TSSLServerSocket.cpp
    )
    include_directories("${OPENSSL_INCLUDE_DIR}")
    list(APPEND SYSLIBS "${OPENSSL_LIBRARIES}")
endif()

# WITH_*THREADS selects whicht threading library to use
if(WITH_BOOSTTHREADS)
    set( USE_BOOST_THREAD 1)
    set( thriftcpp_threads_SOURCES
        src/thrift/concurrency/BoostThreadFactory.cpp
        src/thrift/concurrency/BoostMonitor.cpp
        src/thrift/concurrency/BoostMutex.cpp
    )
    list(APPEND SYSLIBS "${Boost_LIBRARIES}")
elseif(POSIX AND NOT WITH_STDTHREADS)
    set( thriftcpp_threads_SOURCES
        src/thrift/concurrency/PosixThreadFactory.cpp
        src/thrift/concurrency/Mutex.cpp
        src/thrift/concurrency/Monitor.cpp
    )
else()
    set( USE_STD_THREAD 1)
    set( thriftcpp_threads_SOURCES
        src/thrift/concurrency/StdThreadFactory.cpp
        src/thrift/concurrency/StdMutex.cpp
        src/thrift/concurrency/StdMonitor.cpp
    )
endif()

# Thrift non blocking server
set( thriftcppnb_SOURCES
    src/thrift/server/TNonblockingServer.cpp
    src/thrift/async/TAsyncProtocolProcessor.cpp
    src/thrift/async/TEvhttpServer.cpp
    src/thrift/async/TEvhttpClientChannel.cpp
)

# Thrift zlib server
set( thriftcppz_SOURCES
    src/thrift/transport/TZlibTransport.cpp
)

# Thrift Qt4 server
set( thriftcppz_SOURCES
    src/thrift/qt/TQIODeviceTransport.cpp
    src/thrift/qt/TQTcpServer.cpp
)


if(WITH_STATIC_LIB)
    add_library(thrift SHARED ${thriftcpp_SOURCES} ${thriftcpp_threads_SOURCES})
    target_link_libraries(thrift ${SYSLIBY})
    #set_target_properties(thrift PROPERTIES PUBLIC_HEADER "${thriftcpp_HEADERS}")
    install(TARGETS thrift
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include)
endif()

if(WITH_STATIC_LIB)
    add_library(thrift_static STATIC ${thriftcpp_SOURCES} ${thriftcpp_threads_SOURCES})
    target_link_libraries(thrift_static ${SYSLIBY})
    install(TARGETS thrift_static
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include)
endif()


if(WITH_LIBEVENT)
    find_package(Libevent REQUIRED)  # Libevent comes with CMake support form upstream
    add_library(thriftnb SHARED ${thriftcpp_SOURCES} ${thriftcppnb_SOURCES})
    target_link_libraries(thriftnb ${SYSLIBY} ${Libevent_LIBRARIES})
    include_directories(${Libevent_INCLUDE_DIR})
    install(TARGETS thriftnb thriftnb_static
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include)
endif()

if(WITH_ZLIB)
    find_package(ZLIB REQUIRED)
    add_library(thriftz SHARED ${thriftcpp_SOURCES} ${thriftcppz_SOURCES})
    target_link_libraries(thriftz ${SYSLIBY} ${ZLIB_LIBRARIES})
    include_directories(${ZLIB_INCLUDE_DIR})
    install(TARGETS thriftz
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include)
endif()


if(WITH_QT4)
    find_package(Qt4 REQUIRED)
    add_library(thriftqt SHARED ${thriftcpp_SOURCES} ${thriftcppqt_SOURCES})
    target_link_libraries(thriftqt ${SYSLIBY} ${QT_LIBRARIES})
    include_directories(${QT_INCLUDES})
    install(TARGETS thriftqt
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include)
endif()

include_directories("${CMAKE_CURRENT_BINARY_DIR}" src)

# Add Some definitions for cmake and generate a config.h file
include(ConfigureChecks)
configure_file(cmake/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/thrift/config.h)

if(NOT MSVC)
    add_definitions("-std=c++0x -pedantic -Wextra")
else()
    add_definitions("-DUNICODE -D_UNICODE")
endif()

# TODO: Make this configurable on windows
if(USE_MT)
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
endif()

# Package it
include(CPackConfig)

# TODO: add test subdir
