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


find_package(Boost 1.53.0 REQUIRED)
find_package(ZLIB)
find_package(OpenSSL)

# Create the thrift compiler
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
   src/thrift/transport/TFileTransport.cpp
   src/thrift/transport/TSimpleFileTransport.cpp
   src/thrift/transport/THttpTransport.cpp
   src/thrift/transport/THttpClient.cpp
   src/thrift/transport/THttpServer.cpp
   src/thrift/transport/TSocket.cpp
   src/thrift/transport/TPipe.cpp
   src/thrift/transport/TPipeServer.cpp
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

if ( OPENSSL_FOUND )
list( APPEND libthrift_SOURCES 
   src/thrift/transport/TSSLSocket.cpp
   src/thrift/transport/TSSLServerSocket.cpp
)
endif ( OPENSSL_FOUND )

set( libthrift_posixthreads_SOURCES 
    src/thrift/concurrency/Mutex.cpp
    src/thrift/concurrency/Monitor.cpp
    src/thrift/concurrency/PosixThreadFactory.cpp
)

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

add_library(thrift SHARED ${libthrift_SOURCES} ${libthrift_posixthreads_SOURCES})
add_library(thrift_boostthreads SHARED ${libthrift_SOURCES} ${libthrift_boostthreads_SOURCES})
add_library(thriftnb SHARED ${libthrift_SOURCES} ${libthriftnb_SOURCES})

if ( ZLIB_FOUND )
    add_library(thriftz SHARED ${libthrift_SOURCES} ${libthriftz_SOURCES})
    target_link_libraries(thriftz ${ZLIB_LIBRARIES})
endif( ZLIB_FOUND )

include_directories(${CMAKE_CURRENT_BINARY_DIR} src)

install(TARGETS thrift LIBRARY DESTINATION lib)

set(CMAKE_CXX_FLAGS "-std=c++0x -pedantic -Wextra")

# TODO add libthriftnb based on libevent existence
# TODO add libthriftqt based on qt existence
# TODO configure option to enable, disable libs
# TODO add test subdir
