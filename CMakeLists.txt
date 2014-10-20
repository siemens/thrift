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

project(thrift)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Some default settings
include(DefineCMakeDefaults)

# Build time options are defined here
include(DefineOptions)
include(DefineInstallationPaths)
# Package it
include(CPackConfig)
include(ConfigureChecks)

# TODO: add `git rev-parse --short HEAD`
# Read the version information from the Autoconf file
file (STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/configure.ac" CONFIGURE_AC REGEX "AC_INIT\\(.*\\)" )

# The following variable is used in the version.h.in file
string(REGEX REPLACE "AC_INIT\\(\\[.*\\], \\[([0-9]+\\.[0-9]+\\.[0-9]+(-dev)?)\\]\\)" "\\1" PACKAGE_VERSION ${CONFIGURE_AC})
message(STATUS "Thrift package version: ${PACKAGE_VERSION}")

# These are internal to CMake
string(REGEX REPLACE "([0-9]+\\.[0-9]+\\.[0-9]+)(-dev)?" "\\1" thrift_VERSION ${PACKAGE_VERSION})
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" thrift_VERSION_MAJOR ${thrift_VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9])+\\.[0-9]+" "\\1" thrift_VERSION_MINOR ${thrift_VERSION})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" thrift_VERSION_PATCH ${thrift_VERSION})
message(STATUS "Thrift version: ${thrift_VERSION} (${thrift_VERSION_MAJOR}.${thrift_VERSION_MINOR}.${thrift_VERSION_PATCH})")

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  # TODO: -pedantic can not be used at the moment because of: https://issues.apache.org/jira/browse/THRIFT-2784
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O2 -Wall -Wextra -pedantic")
endif()

find_package(Threads)

include(CTest)
if(BUILD_TESTING)
  message(STATUS "Building with unittests")
else ()
  message(STATUS "Building without tests")
endif ()

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/compiler/cpp)

if(WITH_CPP)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/lib/cpp)
endif()

if(WITH_C_GLIB)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/lib/c_glib)
endif()

if(WITH_JAVA)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/lib/java)
endif()

# create a Distribution Package for the Apache Thrift
set(CPACK_PACKAGE_NAME "Apache Thrift")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Apache Thrift")
set(CPACK_PACKAGE_VENDOR "Apache Software Foundation" )
set(CPACK_PACKAGE_CONTACT "dev@thrift.apache.org")
set(CPACK_PACKAGE_VERSION ${thrift_VERSION})
set(CPACK_PACKAGE_VERSION_MAJOR ${thrift_VERSION_MAJOR} )
set(CPACK_PACKAGE_VERSION_MINOR ${thrift_VERSION_MINOR} )
set(CPACK_PACKAGE_VERSION_PATCH ${thrift_VERSION_PATCH} )
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")


if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_HELP_LINK "http://thrift.apache.org")
    set(CPACK_NSIS_MENU_LINKS
        "http://thrift.apache.org" "Apache Thrift - Web Site"
        "https://issues.apache.org/jira/browse/THRIFT" "Apache Thrift - Issues")
    set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
    set(CPACK_NSIS_MODIFY_PATH "ON")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})
else()
    set(CPACK_GENERATOR "DEB" )
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${CPACK_PACKAGE_CONTACT})
endif()

