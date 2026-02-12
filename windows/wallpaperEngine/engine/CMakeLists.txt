cmake_minimum_required(VERSION 3.16)
project(wallpaper_engine LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 修复 C4819: 中文字符编码
if(MSVC)
    add_compile_options(/utf-8)
endif()

add_library(wallpaper_engine STATIC
    api.cpp
    desktop_embed.cpp
    webview2_engine.cpp
)

target_include_directories(wallpaper_engine PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# 静态库构建时 WALLPAPER_API 为空
target_compile_definitions(wallpaper_engine PUBLIC WALLPAPER_ENGINE_STATIC)

# WebView2: 需 vcpkg install webview2
find_package(unofficial-webview2 CONFIG REQUIRED)
target_link_libraries(wallpaper_engine PUBLIC unofficial::webview2::webview2)
target_link_libraries(wallpaper_engine PRIVATE Shlwapi pathcch)

target_compile_definitions(wallpaper_engine PRIVATE _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS)
