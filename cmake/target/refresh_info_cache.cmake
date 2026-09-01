include_guard()

function(refresh_info_cache_add_global_target TARGET)
    if (FPRIME_IS_SUB_BUILD)
        add_custom_target("${TARGET}")
        return()
    endif()
    set(STAMP "${CMAKE_BINARY_DIR}/info-cache-refresh.stamp")
    add_custom_command(
        OUTPUT "${STAMP}"
        COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}/sub-build-info-cache" --target fpp_depend
        COMMAND "${CMAKE_COMMAND}" -E touch "${STAMP}"
        DEPENDS $<TARGET_PROPERTY:${TARGET},FPP_SOURCES>
        VERBATIM
    )
    add_custom_target("${TARGET}" DEPENDS "${STAMP}")
endfunction(refresh_info_cache_add_global_target)

function(refresh_info_cache_add_deployment_target MODULE TARGET SOURCES DEPENDENCIES FULL_DEPENDENCIES)
    refresh_info_cache_add_module_target("${MODULE}" "${TARGET}" "${SOURCES}" "${DEPENDENCIES}")
endfunction(refresh_info_cache_add_deployment_target)

function(refresh_info_cache_add_module_target MODULE TARGET SOURCES DEPENDENCIES)
    if (FPRIME_IS_SUB_BUILD)
        return()
    endif()
    if (TARGET "${MODULE}")
        add_dependencies("${MODULE}" "${TARGET}")
    endif()
endfunction(refresh_info_cache_add_module_target)
