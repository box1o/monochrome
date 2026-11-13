add_library(ps_device
    src/device.cpp
    src/transport.cpp
    src/telemetry.cpp
    src/queue.cpp
    src/session.cpp
    src/commands.cpp
    src/operations.cpp
    src/write.cpp
    src/set.cpp
    src/output.cpp
    src/settings.cpp
    src/protection.cpp
    src/preset.cpp
    src/transport.hpp
    include/ps/device.hpp
)

add_library(ps::device ALIAS ps_device)
set_target_properties(ps_device PROPERTIES AUTOMOC ON)
target_include_directories(ps_device PUBLIC include)
target_link_libraries(ps_device PUBLIC ps::protocol Qt6::Core PRIVATE Qt6::SerialPort)
