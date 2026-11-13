add_library(ps_protocol src/frame.cpp src/decoder.cpp include/ps/protocol.hpp include/ps/result.hpp)
add_library(ps::protocol ALIAS ps_protocol)
target_include_directories(ps_protocol PUBLIC include)
target_compile_features(ps_protocol PUBLIC cxx_std_23)
