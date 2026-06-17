# Logos Module Loader contract tests

add_executable(logos_module_loader_tests
    test_contract.cpp
)

target_link_libraries(logos_module_loader_tests PRIVATE
    logos_module_loader
    GTest::gtest
    GTest::gtest_main
    nlohmann_json::nlohmann_json
)

target_include_directories(logos_module_loader_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/src
)

gtest_discover_tests(logos_module_loader_tests)
