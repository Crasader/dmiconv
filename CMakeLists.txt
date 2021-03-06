cmake_minimum_required(VERSION 2.8)

PROJECT(dmiconv)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
INCLUDE(cmake/ModuleImport.cmake)
INCLUDE(cmake/ModuleCompileOptions.cmake)
ModuleSetCompileOptions()

ADD_DEFINITIONS(-DUSE_DMICONV)
IF (WIN32)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/src/windows)
ENDIF(WIN32)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/src)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/test)

IF (WIN32)
   SET(ICONV_VERSION_STRING "1.11.1")
   SET(ICONV_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/win/include")
   SET(ICONV_LIBRARIES "iconv" "charset")

   INCLUDE_DIRECTORIES(${ICONV_INCLUDE_DIRS})
   LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/win/lib)

   MESSAGE(STATUS "Found Iconv version: ${ICONV_VERSION_STRING}")
   MESSAGE(STATUS "Using Iconv include dir(s): ${ICONV_INCLUDE_DIRS}")
   MESSAGE(STATUS "Using Iconv lib(s): ${ICONV_LIBRARIES}")
ELSE(WIN32)
    MESSAGE(STATUS "Looking for libiconv")
    FIND_PACKAGE(Iconv)

    IF(ICONV_FOUND)
        MESSAGE(STATUS "Found Iconv version: ${ICONV_VERSION_STRING}")
        MESSAGE(STATUS "Using Iconv include dir(s): ${ICONV_INCLUDE_DIRS}")
        MESSAGE(STATUS "Using Iconv lib(s): ${ICONV_LIBRARIES}")
    ELSE(ICONV_FOUND)
        SET(ICONV_VERSION_STRING "1.11.1")
        SET(ICONV_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/unix/include")
	SET(ICONV_LIBRARIES "")
        #SET(ICONV_LIBRARIES "libiconv" "libcharset")
        LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/unix/lib)
        LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/unix/lib/.libs)	
    ENDIF()

   INCLUDE_DIRECTORIES(${ICONV_INCLUDE_DIRS})
ENDIF(WIN32)

FILE(GLOB_RECURSE DMICONV_SOURCES
${CMAKE_CURRENT_SOURCE_DIR}/include/*.cpp
${CMAKE_CURRENT_SOURCE_DIR}/include/*.cc
${CMAKE_CURRENT_SOURCE_DIR}/include/*.c
${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp
${CMAKE_CURRENT_SOURCE_DIR}/include/*.h

${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc
${CMAKE_CURRENT_SOURCE_DIR}/src/*.c
${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp
${CMAKE_CURRENT_SOURCE_DIR}/src/*.h
)

IF (WIN32)
    LIST(APPEND DMICONV_SOURCES)
ENDIF(WIN32)

FILE(GLOB_RECURSE DMICONVTEST_SOURCES
${CMAKE_CURRENT_SOURCE_DIR}/test/*.cpp
${CMAKE_CURRENT_SOURCE_DIR}/test/*.cc
${CMAKE_CURRENT_SOURCE_DIR}/test/*.c
${CMAKE_CURRENT_SOURCE_DIR}/test/*.hpp
${CMAKE_CURRENT_SOURCE_DIR}/test/*.h)

IF (WIN32)
    ADD_LIBRARY(dmiconv ${DMICONV_SOURCES})
    TARGET_LINK_LIBRARIES(dmiconv ${ICONV_LIBRARIES})

    ADD_EXECUTABLE(dmiconvtest ${DMICONVTEST_SOURCES})
    TARGET_LINK_LIBRARIES(dmiconvtest dmiconv ${ICONV_LIBRARIES})

    ADD_CUSTOM_COMMAND(
	TARGET dmiconvtest
	PRE_BUILD
	COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/win/bin/iconv.dll
	$<TARGET_FILE_DIR:dmiconvtest>
    )
    ADD_CUSTOM_COMMAND(
	TARGET dmiconvtest
	PRE_BUILD
	COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/libiconv/win/bin/charset.dll
	$<TARGET_FILE_DIR:dmiconvtest>
    )
ELSE(WIN32)
    ADD_DEFINITIONS(-DLIBICONV_PLUG)

    ADD_LIBRARY(dmiconv ${DMICONV_SOURCES})
    TARGET_LINK_LIBRARIES(dmiconv ${ICONV_LIBRARIES})

    ADD_EXECUTABLE(dmiconvtest ${DMICONVTEST_SOURCES})
    TARGET_LINK_LIBRARIES(dmiconvtest dmiconv ${ICONV_LIBRARIES})
ENDIF(WIN32)
