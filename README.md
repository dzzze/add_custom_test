# Testing in CMake with dependencies

## Motivation

CMake's built-in `test` target runs all tests that have been declared as part of the project.
While this behavior is great for the initial build or in CI, if it is used as part of the
regular development cycle with incremental builds, it triggers tests for many parts of a
larger project that is untouched. While CMake provides the capabilities of declaring
dependencies between targets, and uses this functionality for incremental builds similar
functionality is not available for tests.

## Usage

```cmake
add_custom_test(
    NAME <name>
    COMMAND <command>
    DEPENDS <dep1> [<dep2> ...])
```

Use `DEPENDS` for any target made by `add_executable` or `add_library`. User-declared custom
targets need to expose their file dependecies. (See section
5 of https://samthursfield.wordpress.com/2015/11/21/cmake-dependencies-between-targets-and-files-and-custom-commands/
for details.) Custom targets can be decorated with a property `dependent_files` that includes all
file dependencies.

`add_custom_test` will internally call `add_test` to declare the test and also add a target
`${PROJECT_NAME}-run-custom-test-<test name>` that can be used to run the test when any of its
dependencies is updated. Furthermore, if there is a target `${PROJECT_NAME}-run-custom-tests`,
The single test target will be added as a dependency so multiple tests can be run by updating
that target.
