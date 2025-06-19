# - Try to find Picotls in hsig_picotls dir @maxin

set(HSIG_PICOTLS_DIR ../picotls)

if (PICOQUIC_FETCH_PTLS)
    set(PTLS_CORE_LIBRARY picotls-core)
    set(PTLS_MINICRYPTO_LIBRARY picotls-minicrypto)

    if(WITH_MBEDTLS)
        find_package_handle_standard_args(PTLS REQUIRED_VARS
            PTLS_CORE_LIBRARY
            PTLS_MINICRYPTO_LIBRARY
            PTLS_INCLUDE_DIR)

        if(PTLS_FOUND)
            set(PTLS_LIBRARIES ${PTLS_CORE_LIBRARY} ${PTLS_MINICRYPTO_LIBRARY})
            # add /hsig subdir for params.h @maxin
            set(PTLS_INCLUDE_DIRS ${PTLS_INCLUDE_DIR})
            set(PTLS_WITH_FUSION_DEFAULT OFF)
        endif()
    else()
        set(PTLS_OPENSSL_LIBRARY picotls-openssl)
        if(WITH_FUSION)
            set(PTLS_FUSION_LIBRARY picotls-fusion)
            set(PTLS_WITH_FUSION_DEFAULT ON)
            set(PTLS_LIBRARIES ${PTLS_CORE_LIBRARY} ${PTLS_OPENSSL_LIBRARY} ${PTLS_FUSION_LIBRARY} ${PTLS_MINICRYPTO_LIBRARY})
        else()
            set(PTLS_WITH_FUSION_DEFAULT OFF)
            set(PTLS_LIBRARIES ${PTLS_CORE_LIBRARY} ${PTLS_OPENSSL_LIBRARY} ${PTLS_MINICRYPTO_LIBRARY})
            unset(PTLS_FUSION_LIBRARY)
        endif()
    endif()
    set(PTLS_INCLUDE_DIRS ${HSIG_PICOTLS_DIR}/include)
else(PICOQUIC_FETCH_PTLS)
    find_path(PTLS_INCLUDE_DIR
        NAMES picotls/openssl.h
        HINTS
            ${PTLS_PREFIX}/include/picotls
            ${HSIG_PICOTLS_DIR}/include
            ${CMAKE_SOURCE_DIR}/${HSIG_PICOTLS_DIR}/include
            ${CMAKE_BINARY_DIR}/${HSIG_PICOTLS_DIR}/include
    )

    set(PTLS_HINTS
        ${PTLS_PREFIX}/lib
        ${HSIG_PICOTLS_DIR}
        ${CMAKE_BINARY_DIR}/${HSIG_PICOTLS_DIR}
        ${CMAKE_SOURCE_DIR}/${HSIG_PICOTLS_DIR}
    )

    find_library(PTLS_CORE_LIBRARY picotls-core HINTS ${PTLS_HINTS})
    find_library(PTLS_MINICRYPTO_LIBRARY picotls-minicrypto HINTS ${PTLS_HINTS})

    if(WITH_MBEDTLS)
        find_package_handle_standard_args(PTLS REQUIRED_VARS
            PTLS_CORE_LIBRARY
            PTLS_MINICRYPTO_LIBRARY
            PTLS_INCLUDE_DIR)

        if(PTLS_FOUND)
            set(PTLS_LIBRARIES ${PTLS_CORE_LIBRARY} ${PTLS_MINICRYPTO_LIBRARY})
            set(PTLS_INCLUDE_DIRS ${PTLS_INCLUDE_DIR})
            set(PTLS_WITH_FUSION_DEFAULT OFF)
        endif()
    else()
        find_library(PTLS_OPENSSL_LIBRARY picotls-openssl HINTS ${PTLS_HINTS})
        find_library(PTLS_FUSION_LIBRARY picotls-fusion HINTS ${PTLS_HINTS})

        if(NOT PTLS_FUSION_LIBRARY)
            include(FindPackageHandleStandardArgs)
            find_package_handle_standard_args(PTLS REQUIRED_VARS
                PTLS_CORE_LIBRARY
                PTLS_OPENSSL_LIBRARY
                PTLS_MINICRYPTO_LIBRARY
                PTLS_INCLUDE_DIR)

            if(PTLS_FOUND)
                set(PTLS_LIBRARIES ${PTLS_CORE_LIBRARY} ${PTLS_OPENSSL_LIBRARY} ${PTLS_MINICRYPTO_LIBRARY})
                set(PTLS_INCLUDE_DIRS ${PTLS_INCLUDE_DIR})
                set(PTLS_WITH_FUSION_DEFAULT OFF)
            endif()
        else()
            include(FindPackageHandleStandardArgs)
            find_package_handle_standard_args(PTLS REQUIRED_VARS
                PTLS_CORE_LIBRARY
                PTLS_OPENSSL_LIBRARY
                PTLS_FUSION_LIBRARY
                PTLS_MINICRYPTO_LIBRARY
                PTLS_INCLUDE_DIR)

            if(PTLS_FOUND)
                set(PTLS_LIBRARIES ${PTLS_CORE_LIBRARY} ${PTLS_OPENSSL_LIBRARY} ${PTLS_FUSION_LIBRARY} ${PTLS_MINICRYPTO_LIBRARY})
                set(PTLS_INCLUDE_DIRS ${PTLS_INCLUDE_DIR} ${HSIG_PICOTLS_DIR}/hsig)
                set(PTLS_WITH_FUSION_DEFAULT ON)
            endif()
        endif()
    endif()
endif(PICOQUIC_FETCH_PTLS)

mark_as_advanced(PTLS_LIBRARIES PTLS_INCLUDE_DIRS)
