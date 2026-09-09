cmake_minimum_required(VERSION 3.10)
project(CMDParse)

set(CMAKE_CXX_STANDARD 17)

add_executable(CMDParse Cross_Converted_BIK.cpp)

if(WIN32)
    target_compile_definitions(CMDParse PRIVATE _UNICODE UNICODE)
endif()
