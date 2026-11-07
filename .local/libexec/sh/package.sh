# VAR=value assignments passed to every build command by package::exec.
# Arrays cannot be exported, and package::exec passes them via env anyway.
_package_env=(
    CFLAGS="-I${HOME}/.local/include -L${HOME}/.local/lib -Wl,-rpath=${HOME}/.local/lib"
    LDFLAGS="-L${HOME}/.local/lib -Wl,-rpath=${HOME}/.local/lib"
)

package::exec() {
    shell::exec_env $(shell::as_array _package_env) "${@}"
}

package::_prefix() {
    # Install into the parent of the build directory unless PACKAGE_PREFIX
    # says otherwise.
    local package_prefix="${PACKAGE_PREFIX:-$(dirname "${PWD}")}"
    print::info "Installation prefix: ${package_prefix} (set PACKAGE_PREFIX to override)"
    echo "${package_prefix}"
}

package::configure() {
    local package_prefix; package_prefix="$(package::_prefix)"
    local configure_args; configure_args=(
        --prefix="${package_prefix}"
        --disable-dependency-tracking
        --disable-debug
        "${@}"
    )

    package::exec ./configure "${configure_args[@]}"
}

package::cmake() {
    local package_prefix; package_prefix="$(package::_prefix)"
    local cmake_args; cmake_args=(
        -DCMAKE_INSTALL_PREFIX:PATH="${package_prefix}"
        -DBUILD_WITH_INSTALL_RPATH=TRUE
        "${@}"
    )

    package::exec cmake "${cmake_args[@]}"
}
