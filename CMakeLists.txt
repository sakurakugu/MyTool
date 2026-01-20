cmake_minimum_required(VERSION 3.16)

# 这个项目只用于 QML / qmlls
set(APP_NAME "MyTool")
project(${APP_NAME} LANGUAGES CXX)

# ---------------- Qt 配置 ----------------
set(QT_COMPONENTS
    Core
    Gui
    Quick
)

find_package(Qt6 REQUIRED COMPONENTS ${QT_COMPONENTS})

set(QT_LIBS "")
foreach(comp ${QT_COMPONENTS})
    list(APPEND QT_LIBS Qt6::${comp})
endforeach()

qt_standard_project_setup(REQUIRES 6.10)

# ---------------- 虚拟目标（不跑，不用） ----------------
qt_add_executable(qml_dummy
    dummy.cpp
)

# dummy.cpp 只是为了满足 CMake
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp
"#include <QGuiApplication>\nint main(){return 0;}\n"
)

# 确保生成的虚拟目标能找到 Qt 头文件/库
target_link_libraries(qml_dummy PRIVATE ${QT_LIBS})

# ---------------- QML 文件收集 ----------------
file(GLOB_RECURSE QML_FILES_ABS
    "${CMAKE_SOURCE_DIR}/ui/*.qml"
)

# 转换为相对路径
set(QML_FILES "")
foreach(qml_file ${QML_FILES_ABS})
    file(RELATIVE_PATH rel_path ${CMAKE_SOURCE_DIR} ${qml_file})
    list(APPEND QML_FILES ${rel_path})
endforeach()

# ---------------- QML 模块（关键） ----------------
qt_add_qml_module(qml_dummy    # 会自动生成 ./.qmlls.ini
    URI ${APP_NAME}            # QML 模块 URI
    VERSION 1.0                # 模块版本
    QML_FILES ${QML_FILES}     # QML 文件列表
)

# ---------------- 单例 示例 ----------------
# set_source_files_properties(
#     ui/components/ThemeManager.qml
#     PROPERTIES QT_QML_SINGLETON_TYPE TRUE
# )

# ---------------- 输出提示 ----------------
message(STATUS "====== ${APP_NAME} 构建配置 =====")
# message(STATUS "QML-only CMake for qmlls enabled")
# message(STATUS "QML files: ${QML_FILES}")
message(STATUS "Qt6 版本: ${Qt6_VERSION}")
message(STATUS "===========================")
