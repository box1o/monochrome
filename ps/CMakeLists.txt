cmake_minimum_required(VERSION 3.25)
project(mps VERSION 0.1.0 LANGUAGES CXX)

include(GNUInstallDirs)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Network SerialPort)
add_subdirectory(modules/protocol)
add_subdirectory(modules/device)
add_subdirectory(modules/ipc)
add_subdirectory(app)

configure_file(systemd/mps.service.in mps.service @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/mps.service" DESTINATION "${CMAKE_INSTALL_DATADIR}/systemd/user")
