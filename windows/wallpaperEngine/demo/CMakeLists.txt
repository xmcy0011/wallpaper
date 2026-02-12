cmake_minimum_required(VERSION 3.16)
project(wallpaper_demo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 修复 C4819: 中文字符编码
if(MSVC)
    add_compile_options(/utf-8)
endif()

# 先构建 engine 库（支持从 demo 目录或项目根目录构建）
set(ENGINE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../engine)
if(NOT TARGET wallpaper_engine AND EXISTS ${ENGINE_DIR}/CMakeLists.txt)
    add_subdirectory(${ENGINE_DIR} ${CMAKE_BINARY_DIR}/engine)
endif()

add_executable(wallpaper_demo WIN32
    main.cpp
)

target_include_directories(wallpaper_demo PRIVATE
    ${ENGINE_DIR}
)

target_link_libraries(wallpaper_demo PRIVATE
    wallpaper_engine
    comdlg32
)
