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

# Find required packages
find_package(Boost 1.53.0 REQUIRED)
include_directories("${Boost_INCLUDE_DIR}")

# SYSLIBS contains libraries that need to be linked to all lib targets
set(SYSLIBS "")

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

# This files don't work on Windows CE as there is no pipe support
# TODO: This files won't work with UNICODE support on windows. If fixed this can be re-added.
if (NOT WINCE AND NOT WIN32)
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
elseif(UNIX AND NOT WITH_STDTHREADS)
    list(APPEND SYSLIBS pthread)
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
set( thriftcppqt_SOURCES
    src/thrift/qt/TQIODeviceTransport.cpp
    src/thrift/qt/TQTcpServer.cpp
)


if(WITH_SHARED_LIB)
    add_library(thrift SHARED ${thriftcpp_SOURCES} ${thriftcpp_threads_SOURCES})
    target_link_libraries(thrift ${SYSLIBS})
    #set_target_properties(thrift PROPERTIES PUBLIC_HEADER "${thriftcpp_HEADERS}")
    install(TARGETS thrift
        RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
        LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
        ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
        PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
endif()

if(WITH_STATIC_LIB)
    add_library(thrift_static STATIC ${thriftcpp_SOURCES} ${thriftcpp_threads_SOURCES})
    target_link_libraries(thrift_static ${SYSLIBS})
    install(TARGETS thrift_static
        RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
        LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
        ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
        PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
endif()

if(WITH_LIBEVENT)
    find_package(Libevent REQUIRED)  # Libevent comes with CMake support form upstream
    include_directories(${Libevent_INCLUDE_DIR})

    if(WITH_SHARED_LIB)
        add_library(thriftnb SHARED ${thriftcppnb_SOURCES})
        target_link_libraries(thriftnb ${SYSLIBS} ${Libevent_LIBRARIES})
        #set_target_properties(thriftnb PROPERTIES PUBLIC_HEADER "${thriftcpp_HEADERS}")
        install(TARGETS thriftnb
            RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
            LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
            ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
            PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
    endif()

    if(WITH_STATIC_LIB)
        add_library(thriftnb_static STATIC ${thriftcppnb_SOURCES})
        target_link_libraries(thriftnb_static ${SYSLIBS} ${Libevent_LIBRARIES})
        install(TARGETS thriftnb_static
            RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
            LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
            ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
            PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
    endif()
endif()

if(WITH_ZLIB)
    find_package(ZLIB REQUIRED)
    include_directories(${ZLIB_INCLUDE_DIR})

    if(WITH_SHARED_LIB)
        add_library(thriftz SHARED ${thriftcppz_SOURCES})
        target_link_libraries(thriftz ${SYSLIBS} ${ZLIB_LIBRARIES})
        #set_target_properties(thriftz PROPERTIES PUBLIC_HEADER "${thriftcpp_HEADERS}")
        install(TARGETS thriftz
            RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
            LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
            ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
            PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
    endif()

    if(WITH_STATIC_LIB)
        add_library(thriftz_static STATIC ${thriftcppz_SOURCES})
        target_link_libraries(thriftz_static ${SYSLIBS} ${ZLIB_LIBRARIES})
        install(TARGETS thriftz_static
            RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
            LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
            ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
            PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
    endif()
endif()


if(WITH_QT4)
    find_package(Qt4 REQUIRED)
    add_library(thriftqt SHARED ${thriftcppqt_SOURCES})

    include_directories(${QT_INCLUDES})
    if(WITH_SHARED_LIB)
        add_library(thriftqt SHARED ${thriftcppqt_SOURCES})
        target_link_libraries(thriftqt ${SYSLIBS} ${QT_LIBRARIES})
        #set_target_properties(thriftqt PROPERTIES PUBLIC_HEADER "${thriftcpp_HEADERS}")
        install(TARGETS thriftqt
            RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
            LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
            ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
            PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
    endif()

    if(WITH_STATIC_LIB)
        add_library(thriftqt_static STATIC ${thriftcppqt_SOURCES})
        target_link_libraries(thriftqt_static ${SYSLIBS} ${QT_LIBRARIES})
        install(TARGETS thriftqt_static
            RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
            LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
            ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
            PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
    endif()
endif()

include_directories("${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/thrift" src)

# Add Some definitions for cmake and generate a config.h file
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/thrift/config.h)


if(MSVC)
    add_definitions("-DUNICODE -D_UNICODE")
endif()

# Install the headers
install(DIRECTORY "src/thrift" DESTINATION "${INCLUDE_INSTALL_DIR}"
    FILES_MATCHING PATTERN "*.h" PATTERN "*.tcc")

add_subdirectory(test)
# TODO: add test subdir
