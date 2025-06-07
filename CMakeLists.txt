cmake_minimum_required (VERSION 3.10)
project (AzteroidsGame)
set(VERSION "0.1.0")

# Required libraries in this source dir

# Отключаем тесты, бенчмарки и примеры EntityX
set(ENTITYX_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(ENTITYX_BUILD_BENCHMARK OFF CACHE BOOL "" FORCE)
set(ENTITYX_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
add_subdirectory(lib/entityx EXCLUDE_FROM_ALL)
add_subdirectory(lib/glfw EXCLUDE_FROM_ALL)




# Поиск и линковка OpenGL и GLUT/freeglut для всех платформ
if (WIN32)
    find_package(OpenGL REQUIRED)
    include_directories(${OPENGL_INCLUDE_DIR})
    find_path(GLUT_INCLUDE_DIR NAMES GL/glut.h)
    find_library(GLUT_LIBRARY NAMES freeglut glut)
    if (NOT GLUT_INCLUDE_DIR OR NOT GLUT_LIBRARY)
        message(FATAL_ERROR "GLUT/freeglut не найден. Установите freeglut (например, через vcpkg: vcpkg install freeglut) или вручную.")
    endif()
    include_directories(${GLUT_INCLUDE_DIR})
elseif(APPLE)
    # На macOS GLUT и OpenGL идут с системой
else()
    find_package(OpenGL REQUIRED)
    include_directories(${OPENGL_INCLUDE_DIR})
    find_package(GLUT REQUIRED)
    include_directories(${GLUT_INCLUDE_DIRS})
endif()


# include paths
include_directories(lib/glfw/include lib/entityx src)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")
file(GLOB_RECURSE azteroids_SOURCES "src/*.cpp")

if (APPLE)
    set(OSX_ICON_FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/Azteroids.icns)
    # set where in the bundle to put the icns files
    set_source_files_properties(${OSX_ICON_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    # include the icns files in the target
    set( azteroids_SOURCES ${azteroids_SOURCES} ${OSX_ICON_FILES} )
endif()


add_executable(Azteroids WIN32 MACOSX_BUNDLE ${azteroids_SOURCES})

if (APPLE)
    set_target_properties(Azteroids PROPERTIES
                          MACOSX_BUNDLE_BUNDLE_NAME "Azteroids"
                          MACOSX_BUNDLE_ICON_FILE   "Azteroids"
                          MACOSX_BUNDLE_SHORT_VERSION_STRING ${VERSION}
                          MACOSX_BUNDLE_LONG_VERSION_STRING "Azteroids - Version ${VERSION}")
endif()

if (MSVC)
    # Tell MSVC to use main instead of WinMain for Windows subsystem executables
    set_target_properties(Azteroids PROPERTIES
                          LINK_FLAGS "/ENTRY:mainCRTStartup")
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (WIN32)
    target_link_libraries(Azteroids entityx glfw ${OPENGL_gl_LIBRARY} ${GLUT_LIBRARY})
elseif(APPLE)
    target_link_libraries(Azteroids entityx glfw "-framework OpenGL" "-framework GLUT")
else()
    target_link_libraries(Azteroids entityx glfw ${OPENGL_gl_LIBRARY} ${GLUT_LIBRARIES})
endif()

