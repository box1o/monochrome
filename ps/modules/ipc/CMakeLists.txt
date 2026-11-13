add_library(ps_ipc
    src/server.cpp
    src/requests.cpp
    src/client.cpp
    src/message.cpp
    include/ps/server.hpp
    include/ps/client.hpp
)

add_library(ps::ipc ALIAS ps_ipc)
set_target_properties(ps_ipc PROPERTIES AUTOMOC ON)
target_include_directories(ps_ipc PUBLIC include)
target_link_libraries(ps_ipc PUBLIC ps::device Qt6::Network)
