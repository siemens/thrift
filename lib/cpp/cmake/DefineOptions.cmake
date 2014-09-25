option(WITH_ZLIB "Build with ZLIB support" OFF)
option(WITH_LIBEVENT "Build with libevent support" OFF)
option(WITH_QT4 "Build with Qt4 support" OFF)
option(WITH_OPENSSL "Build with OpenSSL support" ON)

option(WITH_BOOSTTHREADS "Build with Boost thread support" OFF)
option(WITH_STDTHREADS "Build with C++ std::thread support" OFF)

option(WITH_SHARED_LIB "Build with a shared library" ON)
option(WITH_STATIC_LIB "Build with a static library" ON)

option(WITH_TESTING "Build with unit tests" OFF)
option(WITH_EXAMPLES "Build examples" ON)



if (WITH_TESTING)
  set(WITH_STATIC_LIB ON)
endif (WITH_TESTING)
