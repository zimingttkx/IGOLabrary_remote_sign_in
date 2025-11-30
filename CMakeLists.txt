cmake_minimum_required(VERSION 3.10)
project(IGOLibrary_remote_sign_in)

set(CMAKE_CXX_STANDARD 20)

add_executable(IGOLibrary_remote_sign_in main.cpp)

# 链接蓝牙库
target_link_libraries(IGOLibrary_remote_sign_in bluetooth)
