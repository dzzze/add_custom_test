# Add test with dependencies.
# Test will run only if any of the dependencies has been updated.
# Additionally test will be added to a target ${PROJECT_NAME}-run-custom-tests if it exists.
# This allows running all tests with updated dependencies at once during the build stage.
function(add_custom_test)
    set(options "")
    set(one_value_args COMMAND NAME)
    set(multi_value_args DEPENDS)
    cmake_parse_arguments(
        ARG
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN})

    foreach (dep ${ARG_DEPENDS})
        list(APPEND deps ${dep})
        # Custom targets need to expose the files that they depend on for a curtom command to be
        # able to depend on them.
        # Read section 5 of https://samthursfield.wordpress.com/2015/11/21/cmake-dependencies-between-targets-and-files-and-custom-commands/
        # for details.
        list(APPEND deps "$<TARGET_PROPERTY:${dep},dependent_files>")
    endforeach ()

    if (ARG_NAME STREQUAL "")
        message(FATAL_ERROR "add_custom_test called without argument for name")
    endif ()

    set(name ${ARG_NAME})

    set(stamp_file "${CMAKE_CURRENT_BINARY_DIR}/${name}_stamp")

    add_custom_command(
        OUTPUT ${stamp_file}
        COMMAND ${ARG_COMMAND}
        COMMAND ${CMAKE_COMMAND} -E touch ${stamp_file}
        USES_TERMINAL
        COMMENT "Running test ${name}"
        DEPENDS ${deps})

    add_custom_target(
        ${PROJECT_NAME}-run-custom-test-${name}
        DEPENDS ${stamp_file})

    set_target_properties(
        ${PROJECT_NAME}-run-custom-test-${name}
        PROPERTIES
        dependent_files ${stamp_file})

    if (TARGET ${PROJECT_NAME}-run-custom-tests)
        add_dependencies(${PROJECT_NAME}-run-custom-tests ${PROJECT_NAME}-run-custom-test-${name})
    endif ()
endfunction()
