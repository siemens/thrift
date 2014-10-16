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

project(libthrift)

# Read the version information from the Autoconf file
file (STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/../../configure.ac" CONFIGURE_AC REGEX "AC_INIT\\(.*\\)" )

# The following variable is used in the version.h.in file
string(REGEX REPLACE "AC_INIT\\(\\[.*\\], \\[([0-9]+\\.[0-9]+\\.[0-9]+(-dev)?)\\]\\)" "\\1" PACKAGE_VERSION ${CONFIGURE_AC})
message(STATUS "Thrift package version: ${PACKAGE_VERSION}")

# These are internal to CMake
string(REGEX REPLACE "([0-9]+\\.[0-9]+\\.[0-9]+)(-dev)?" "\\1" thrift_VERSION ${PACKAGE_VERSION})
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" thrift_VERSION_MAJOR ${thrift_VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9])+\\.[0-9]+" "\\1" thrift_VERSION_MINOR ${thrift_VERSION})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" thrift_VERSION_PATCH ${thrift_VERSION})
message(STATUS "Thrift version: ${thrift_VERSION} (${thrift_VERSION_MAJOR}.${thrift_VERSION_MINOR}.${thrift_VERSION_PATCH})")

# add definitions
include(DefineCMakeDefaults.cmake)
include(DefinePlatformDefaults.cmake)
include(DefineCompilerFlags.cmake)
include(DefineInstallationPaths.cmake)
include(DefineOptions.cmake)

include(ConfigureChecks.cmake)
configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/thrift/config.h)

find_package(Boost 1.53.0 REQUIRED)
find_package(ZLIB)
find_package(OpenSSL)

# Create the thrift C++ library
set( libthrift_SOURCES 
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

# This files don't work on Windows CE as there is no pipe support
if (NOT WINCE)
    list(APPEND libthrift_SOURCES
       src/thrift/transport/TPipe.cpp
       src/thrift/transport/TPipeServer.cpp
       src/thrift/transport/TFileTransport.cpp
    )   
endif()


if (WIN32)
    list(APPEND libthrift_SOURCES
        src/thrift/windows/TWinsockSingleton.cpp
        src/thrift/windows/SocketPair.cpp
        src/thrift/windows/GetTimeOfDay.cpp
        src/thrift/windows/WinFcntl.cpp
    )
    if(NOT WINCE)
        # This file uses pipes so it currently won't work on Windows CE
        list(APPEND libthrift_SOURCES
            src/thrift/windows/OverlappedSubmissionThread.cpp
        )
    endif()
endif()


if(OPENSSL_FOUND AND WITH_OPENSSL)
    list( APPEND libthrift_SOURCES 
       src/thrift/transport/TSSLSocket.cpp
       src/thrift/transport/TSSLServerSocket.cpp
    )
endif()

if(POSIX AND NOT FORCE_STDTHREADS)
    set( libthrift_threads_SOURCES
        src/thrift/concurrency/PosixThreadFactory.cpp
        src/thrift/concurrency/Mutex.cpp
        src/thrift/concurrency/Monitor.cpp
    )
else()
    set( libthrift_threads_SOURCES
        src/thrift/concurrency/StdThreadFactory.cpp
        src/thrift/concurrency/StdMutex.cpp
        src/thrift/concurrency/StdMonitor.cpp
    )
endif()


set( libthrift_boostthreads_SOURCES 
    src/thrift/concurrency/BoostThreadFactory.cpp
    src/thrift/concurrency/BoostMonitor.cpp
    src/thrift/concurrency/BoostMutex.cpp
)

set( libthriftnb_SOURCES
    src/thrift/server/TNonblockingServer.cpp
    src/thrift/async/TAsyncProtocolProcessor.cpp
    src/thrift/async/TEvhttpServer.cpp
    src/thrift/async/TEvhttpClientChannel.cpp
)

set( libthriftz_SOURCES
    src/thrift/transport/TZlibTransport.cpp
)

add_library(thrift SHARED ${libthrift_SOURCES} ${libthrift_threads_SOURCES})

if(WITH_STATIC_LIB)
add_library(thrift_static STATIC ${libthrift_SOURCES} ${libthrift_threads_SOURCES})
endif()

if (Boost_FOUND)
    add_library(thrift_boostthreads SHARED ${libthrift_SOURCES} ${libthrift_boostthreads_SOURCES})
    target_link_libraries(thrift_boostthreads ${Boost_LIBRARIES})
endif()

if(Libevent_FOUND) # Libevent comes with CMake support form upstream
    add_library(thriftnb SHARED ${libthrift_SOURCES} ${libthriftnb_SOURCES})
    target_link_libraries(thriftnb ${Libevent_LIBRARIES})
endif()

if(ZLIB_FOUND)
    add_library(thriftz SHARED ${libthrift_SOURCES} ${libthriftz_SOURCES})
    target_link_libraries(thriftz ${ZLIB_LIBRARIES})
endif(ZLIB_FOUND)

include_directories(${CMAKE_CURRENT_BINARY_DIR} src)

install(TARGETS thrift LIBRARY DESTINATION lib)

if(NOT MSVC)
    add_definitions( "-std=c++0x -pedantic -Wextra")
endif()

# TODO add libthriftqt based on qt existence
# TODO configure option to enable, disable libs
# TODO add test subdir
