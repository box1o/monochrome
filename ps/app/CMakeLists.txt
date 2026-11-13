add_executable(mps
    main.cpp
    application.cpp
    cli/options.cpp
    cli/command.cpp
    service/service.cpp
    service/shutdown.cpp
)

target_link_libraries(mps PRIVATE ps::ipc)
install(TARGETS mps RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
