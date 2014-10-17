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
find_package(GTK2 REQUIRED)
include_directories("${GTK2_INCLUDE_DIRS}")

include_directories(src)

# SYSLIBS contains libraries that need to be linked to all lib targets
set(SYSLIBS "${GTK2_LIBRARIES}")

# Create the thrift C glib library
set(thrift_c_glib_SOURCES
    src/thrift/c_glib/thrift.c
    src/thrift/c_glib/thrift_struct.c
    src/thrift/c_glib/thrift_application_exception.c
    src/thrift/c_glib/processor/thrift_processor.c
    src/thrift/c_glib/processor/thrift_dispatch_processor.c
    src/thrift/c_glib/protocol/thrift_protocol.c
    src/thrift/c_glib/protocol/thrift_protocol_factory.c
    src/thrift/c_glib/protocol/thrift_binary_protocol.c
    src/thrift/c_glib/protocol/thrift_binary_protocol_factory.c
    src/thrift/c_glib/transport/thrift_transport.c
    src/thrift/c_glib/transport/thrift_transport_factory.c
    src/thrift/c_glib/transport/thrift_buffered_transport_factory.c
    src/thrift/c_glib/transport/thrift_framed_transport_factory.c
    src/thrift/c_glib/transport/thrift_socket.c
    src/thrift/c_glib/transport/thrift_server_transport.c
    src/thrift/c_glib/transport/thrift_server_socket.c
    src/thrift/c_glib/transport/thrift_buffered_transport.c
    src/thrift/c_glib/transport/thrift_framed_transport.c
    src/thrift/c_glib/transport/thrift_memory_buffer.c
    src/thrift/c_glib/server/thrift_server.c
    src/thrift/c_glib/server/thrift_simple_server.c
)

if(WITH_SHARED_LIB)
    add_library(thrift_c_glib SHARED ${thrift_c_glib_SOURCES})
    target_link_libraries(thrift_c_glib ${SYSLIBS})
    install(TARGETS thrift_c_glib
        RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
        LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
        ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
        PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
endif()

if(WITH_STATIC_LIB)
    add_library(thrift_c_glib_static STATIC ${thrift_c_glib_SOURCES})
    target_link_libraries(thrift_c_glib_static ${SYSLIBS})
    install(TARGETS thrift_c_glib_static
        RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
        LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
        ARCHIVE DESTINATION "${LIB_INSTALL_DIR}"
        PUBLIC_HEADER DESTINATION "${INCLUDE_INSTALL_DIR}")
endif()

# Install the headers
install(DIRECTORY "src/thrift" DESTINATION "${INCLUDE_INSTALL_DIR}"
    FILES_MATCHING PATTERN "*.h")

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
